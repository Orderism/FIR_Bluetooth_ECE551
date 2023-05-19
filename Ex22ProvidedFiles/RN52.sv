module RN52(clk,RST_n,cmd_n,RX,TX,I2S_sclk,I2S_data,I2S_ws);

  ///////////////////////////////////////////////////
  // Models RN52.  Only simple ACK responses      //
  // I2S data is from tone_ROM_lft/tone_ROM_rght //
  ////////////////////////////////////////////////
  input clk,RST_n;
  input cmd_n;		// indicates it is in command mode
  input RX;
  output TX;
  output I2S_sclk;
  output I2S_data;
  output I2S_ws;
  
  typedef enum reg[1:0] {IDLE, SEND_BYTE, WAIT_RESP, DISPATCH } state_t;
  
  state_t state, nxt_state;
  
  ///////////////////////////////////
  // Define state machine outputs //
  /////////////////////////////////
  logic [3:0] resp_start;
  logic [2:0] resp_len;
  logic send_byte;
  logic load_addr;
  logic inc_addr;
  logic inc_song,dec_song;
  
  ///////////////////////////////
  // Declare needed registers //
  /////////////////////////////
  reg [3:0] addr,addr_stop;
  reg [1:0] song;		// determines routing of left/right tone_ROM outputs
  reg [7:0] last_byte_cmd;	// stores last byte of command that is not \r
  
  ///////////////////////////////
  // Declare internal signals //
  /////////////////////////////
  wire tx_done,rx_rdy,RX,TX,last_byte;
  wire [7:0] tx_data,rx_data;
  
  ///////////////////////
  // Instantiate UART //
  /////////////////////
  UART iUART(.clk(clk),.rst_n(RST_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy),
             .clr_rx_rdy(rx_rdy),.rx_data(rx_data),.trmt(send_byte),
			 .tx_data(tx_data),.tx_done(tx_done));

  ///////////////////////////
  // Instantiate resp ROM //
  /////////////////////////
  resp_ROM iRESP(.clk(clk),.addr(addr),.dout(tx_data));
  
  //////////////////////////////
  // Instantiate I2S_Monarch //
  ////////////////////////////
  I2S_Mnrch iI2S_Mnrch(.clk(clk),.rst_n(RST_n),.I2S_sclk(I2S_sclk),
                       .I2S_data(I2S_data),.I2S_ws(I2S_ws),.song(song));

  ////////////////////////////////////
  // Store last byte of command //
  ///////////////////////////////
  always_ff @(posedge clk)
    if ((rx_rdy) && (rx_data!==8'h0D))
	  last_byte_cmd <= rx_data;

  /////////////////////////////////////////////
  // song start at 00 and goes up/dwn down  //
  // depending on next/prev buttons        //
  //////////////////////////////////////////
  always_ff @(posedge clk, negedge RST_n)
    if (!RST_n)
	  song <= 2'b00;
	else if (inc_song)
	  song <= song + 1;
	else if (dec_song)
	  song <= song - 1;
	  
  ///////////////////////////////////
  // addr register to command ROM //
  /////////////////////////////////
  always_ff @(posedge clk)
    if (load_addr)
	  addr <= resp_start;
	else if (inc_addr)
	  addr <= addr + 1;

  //// Capture stopping address ////	
  always_ff @(posedge clk)
    if (load_addr)
	  addr_stop <= resp_start + resp_len;
	  
  assign last_byte = (addr==addr_stop) ? 1'b1 : 1'b0;	  
			 
  /////////////////////////
  // define state flops // 
  ///////////////////////
  always_ff @(posedge clk, negedge RST_n)
    if (!RST_n)
	  state <= IDLE;
	else
	  state <= nxt_state;

  always_comb begin
    resp_start = 4'bxxxx;
	resp_len = 3'bxxx;
	send_byte = 0;
	load_addr = 0;
	inc_addr = 0;
	inc_song = 0;
	dec_song = 0;
    nxt_state = IDLE;

	case (state)
	  IDLE : begin
		resp_start = 4'b0000;
		resp_len = 3'b101;
		load_addr = 1;	    
	    if (!cmd_n)
		  nxt_state = SEND_BYTE;
	  end
	  SEND_BYTE : begin
	    send_byte = 1;
		inc_addr = 1;
	    nxt_state = WAIT_RESP;
	  end
	  WAIT_RESP : begin
	    if ((last_byte) && (tx_done))
		  nxt_state = DISPATCH;
		else if (tx_done)
		  nxt_state = SEND_BYTE;
		else
		  nxt_state = WAIT_RESP;
	  end
	  DISPATCH : begin
		resp_start = 4'b0101;		//send ACK
		resp_len = 3'b101;
		load_addr = 1;
	    if ((rx_rdy) && (rx_data==8'h0D)) begin
          nxt_state = SEND_BYTE;
		  inc_song = (last_byte_cmd==8'h2B) ? 1 : 0;
          dec_song = (last_byte_cmd==8'h2D) ? 1 : 0;	  
		end else
		  nxt_state = DISPATCH;
	  end
	endcase
	
  end

  
endmodule