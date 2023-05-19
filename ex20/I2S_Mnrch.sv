module I2S_Mnrch(clk,rst_n,I2S_sclk,I2S_data,I2S_ws,song);

  input clk,rst_n;
  input [1:0] song;
  output reg I2S_sclk;		// 2.11MHz 24 clocks high, 24 clocks low
  output I2S_data;			// capture data at rising edge detect
  output reg I2S_ws;			// 0 => left,  1 => right

  typedef enum reg {LFT, RGHT } state_t;
  
  state_t state,nxt_state;
 
  //////////////////////////////
  // Define needed registers //
  //////////////////////////// 
  reg [3:0] sclk_div;
  reg [4:0] bit_cnt;
  reg [11:0] addrTR;		// one of 4096
  reg [47:0] shft_reg;		// holds {right,left} data to transmit
  
  
  ///////////////////////////////
  // Declare internal signals //
  /////////////////////////////
  wire [15:0] doutL,doutR;				// 16-bit outputs of tone ROMs
  wire [15:0] doutL_used,doutR_used; 	// can differ depending on song
  wire tggl_sclk, sclk_fall_nxt;
  
  /////////////////////////
  // Declare SM outputs //
  ///////////////////////
  logic nxt_smpl,clr_bit_cnt,tggl_ws;
  
  ///////////////////////////////////////////////
  // Instantiate tone_ROMs for left and right //
  /////////////////////////////////////////////
  tone_ROM_lft iLTR(.clk(clk),.addr(addrTR),.dout(doutL));
  tone_ROM_rght iRTR(.clk(clk),.addr(addrTR),.dout(doutR));
  
  ////////////////////////////////////////////////////
  // Song determines a mixing around of left/right //
  //////////////////////////////////////////////////
  assign doutL_used = (song==2'b00) ? doutL :
                      (song==2'b01) ? doutR :
					  (song==2'b10) ? doutL-doutR :
					  doutL+doutR;
					  
  assign doutR_used = (song==2'b00) ? doutR :
                      (song==2'b01) ? doutL :
					  (song==2'b10) ? doutR+doutL :
					  doutR-doutL;
  
  /////////////////////////////
  // infer sclk_div circuit //
  ///////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  sclk_div <= 4'b0000;
	else if (tggl_sclk)
	  sclk_div <= 4'b0000;
	else
	  sclk_div <= sclk_div + 1;
	  
  assign tggl_sclk = (sclk_div == 4'd11) ? 1'b1 : 1'b0;
  assign sclk_fall_nxt = tggl_sclk & I2S_sclk;
  
  //////////////////////////////////////
  // SCLK comes from a toggling flop //
  ////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  I2S_sclk <= 1'b1;		// start with sclk high
	else if (tggl_sclk)
	  I2S_sclk <= ~I2S_sclk;

  ////////////////////////
  // Infer bit counter //
  //////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  bit_cnt <= 5'b00001;
	else if (clr_bit_cnt)
	  bit_cnt <= 5'b00000;
	else if (sclk_fall_nxt)
	  bit_cnt <= bit_cnt + 1;
	  
  ////////////////////////////////////
  // WS comes from a toggling flop //
  //////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  I2S_ws <= 1'b1;		// start with sclk high
	else if (tggl_ws)
	  I2S_ws <= ~I2S_ws;
	  
  ////////////////////////////
  // Infer toneROM address //
  //////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  addrTR <= 7'h00;
	else if (nxt_smpl)
	  addrTR <= addrTR + 1;

  ///////////////////////////
  // infer shift register //
  /////////////////////////
  always_ff @(posedge clk)
    if (nxt_smpl)
	  shft_reg <= {doutL_used,8'h00,doutR_used,8'h00};
    else if (sclk_fall_nxt)
      shft_reg <= {shft_reg[46:0],1'b0};

  assign I2S_data = shft_reg[47];	  
	  
	  
  ////////////////////////
  // Infer state flops //
  //////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      state <= LFT;
    else
      state <= nxt_state;
  
  always_comb begin
    ///////////////////////////////////////////
	// Default outputs to most common state //
	/////////////////////////////////////////
	nxt_smpl = 0;
	tggl_ws = 0;
	clr_bit_cnt = 0;
	nxt_state = LFT;
	
	case (state)
	  LFT : begin
	    tggl_ws = (bit_cnt==5'd22) ? sclk_fall_nxt : 1'b0;
	    if ((bit_cnt==5'd23) && (sclk_fall_nxt)) begin
		  nxt_state = RGHT;
		  clr_bit_cnt = 1;
		  nxt_smpl = 1;
		end
	  end
	  RGHT : begin
	    tggl_ws = (bit_cnt==5'd22) ? sclk_fall_nxt : 1'b0;
	    if ((bit_cnt==5'd23) && (sclk_fall_nxt)) begin
		  nxt_state = LFT;
		  clr_bit_cnt = 1;
		end else
		  nxt_state = RGHT;
	  end
	endcase
	
  end
  
endmodule