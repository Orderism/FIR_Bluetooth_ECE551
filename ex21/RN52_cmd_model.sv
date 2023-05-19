module RN52_cmd_model(clk,rst_n,initialized,RX,TX);

  input clk,rst_n;
  input RX;
  output TX;
  output initialized;
  
  typedef enum reg[1:0] {SEND_BYTE, WAIT_RESP, DISPATCH } state_t;
  
  state_t state, nxt_state;
  
  /////////////////////////////////
  // Define arrays for response //
  // data and cmd buffer       //
  //////////////////////////////
  reg [7:0]resp_data[0:15];
  reg [7:0]cmd[0:15];
  
  ///////////////////////////////////
  // Define state machine outputs //
  /////////////////////////////////
  logic [3:0] resp_start;
  logic [2:0] resp_len;
  logic send_byte;		// initiate UART transmission
  logic load_addr;		// load the stop_addr with resp_start+resp_len
  logic inc_addr;		// increment addr of resp string
  logic capture;		// capture incoming cmd byte
  logic set_ADV_name;	// set true in SM if SN,ECE551 command came in
  logic set_I2S_mode;	// set true in SM if S|,01 command came in
  logic rst_cmd_addr;	// resets address pointer for cmd string
  
  ///////////////////////////////
  // Declare needed registers //
  /////////////////////////////
  reg [3:0] addr,addr_stop;
  reg [3:0] cmd_addr;				// points to next byte in cmd[] buffer
  reg I2S_mode, ADV_name;			// set flops for have commands been received properly
  
  ///////////////////////////////
  // Declare internal signals //
  /////////////////////////////
  wire tx_done,rx_rdy,RX,TX,last_byte;
  wire [7:0] tx_data,rx_data;
  wire ADV_NAME, I2S_MODE;			// decodes of cmd[]
  
  ///////////////////////
  // Instantiate UART //
  /////////////////////
  UART iUART(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy),
             .clr_rx_rdy(rx_rdy),.rx_data(rx_data),.trmt(send_byte),
			 .tx_data(tx_data),.tx_done(tx_done));

  assign tx_data = resp_data[addr];
			 
  ///////////////////////////////////////
  // addr register of response string //
  /////////////////////////////////////
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
	
  //////////////////////////////////
  // addr register of cmd string //
  ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  cmd_addr <= 4'b0000;
	else if (rst_cmd_addr)
	  cmd_addr <= 4'b0000;
	else if (capture)
	  cmd_addr <= cmd_addr + 1;
	  
  /////////////////////////////////////////
  // capture incoming command in buffer //
  ///////////////////////////////////////
  always_ff @(posedge clk)
    if (capture)
      cmd[cmd_addr] = rx_data;	
	  
  ////////////////////////////////////////////////
  // Infer set flops for I2S_MODE and ADV_NAME //
  //////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      I2S_mode <= 1'b0;
	else if (set_I2S_mode)
	  I2S_mode <= 1'b1;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      ADV_name <= 1'b0;
	else if (set_ADV_name)
	  ADV_name <= 1'b1;	  	

  assign initialized = I2S_mode & ADV_name;	  
	  
  /////////////////////////
  // define state flops // 
  ///////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= DISPATCH;
	else
	  state <= nxt_state;

  always_comb begin
    resp_start = 4'bxxxx;
	resp_len = 3'bxxx;
	send_byte = 0;
	load_addr = 0;
	inc_addr = 0;
	capture = 0;
	rst_cmd_addr = 0;
	set_I2S_mode = 0;
	set_ADV_name = 0;
    nxt_state = DISPATCH;

	case (state)
	  SEND_BYTE : begin
	    send_byte = 1;
		inc_addr = 1;
		rst_cmd_addr = 1;
		set_I2S_mode = I2S_MODE;
		set_ADV_name = ADV_NAME;
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
	    if ((rx_rdy) && (rx_data==8'h0D))
          nxt_state = SEND_BYTE;		  
		else if (rx_rdy) begin
		  capture = 1;
		  nxt_state = DISPATCH;
		end else
		  nxt_state = DISPATCH;
	  end
	endcase
	
  end

  initial begin
    resp_data[0] = 8'h43;	//C
	resp_data[1] = 8'h4D;	//M
	resp_data[2] = 8'h44;	//D
	resp_data[3] = 8'h0D;	//\r
	resp_data[4] = 8'h0A;	//\n
    resp_data[5] = 8'h41;	//A
	resp_data[6] = 8'h43;	//C
	resp_data[7] = 8'h4B;	//K
	resp_data[8] = 8'h0D;	//\r
	resp_data[9] = 8'h0A;	//\n	
  end
  
  assign I2S_MODE = ((cmd[0]==8'h53) && (cmd[1]==8'h7C) && (cmd[2]==8'h2C) && (cmd[3]==8'h30) && (cmd[4]==8'h31)) ? 1'b1 : 1'b0;
  assign ADV_NAME = ((cmd[0]==8'h53) && (cmd[1]==8'h4E) && (cmd[2]==8'h2C) && (cmd[3]==8'h45) && (cmd[4]==8'h43)) ? 1'b1 : 1'b0;
    
endmodule