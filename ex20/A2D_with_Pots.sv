module A2D_with_Pots(clk,rst_n,SS_n,SCLK,MISO,MOSI,LP,B1,B2,B3,HP,VOL);
  ///////////////////////////////////////////////|
  // Model of a National Semi Conductor ADC128S ||
  // 12-bit A2D converter.                      ||
  // Models the A2D connected to slide pots for ||
  // the equalizer project.                     ||
  ////////////////////////////////////////////////


  input clk,rst_n;		// clock and active low asynch reset
  input [11:0] LP,B1,B2,B3,HP,VOL;	// represent the slide pot readings
  input SS_n;			// active low slave select
  input SCLK;			// Serial clock
  input MOSI;			// serial data in from master
  
  output MISO;			// serial data out to master
  
  wire [15:0] A2D_data,cmd;
  wire rdy_rise;
	
  typedef enum reg {FIRST,SECOND} state_t;
  
  state_t state,nxt_state;
  
  ///////////////////////////////////////////////
  // Registers needed in design declared next //
  /////////////////////////////////////////////
  reg rdy_ff;				// used for edge detection on rdy
  reg [2:0] channel;		// pointer to last channel specified for A2D conversion to be performed on.
  reg [11:0] value;
  
  /////////////////////////////////////////////
  // SM outputs declared as type logic next //
  ///////////////////////////////////////////
  logic update_ch,dec_value;

  ////////////////////////////////
  // Instantiate SPI interface //
  //////////////////////////////
  SPI_ADC128S iSPI(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),
                 .MOSI(MOSI),.A2D_data(A2D_data),.cmd(cmd),.rdy(rdy));

	  
  //// channel pointer ////	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  channel <= 3'b000;
	else if (update_ch) begin
	  channel <= cmd[13:11];
	end
	
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  value <= 12'hC00;
	else if (dec_value)
	  value <= value - 12'h010;
	  
  //// Infer state register next ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= FIRST;
	else
	  state <= nxt_state;
	  
  //// positive edge detection on rdy ////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  rdy_ff <= 1'b0;
	else
	  rdy_ff <= rdy;
  assign rdy_rise = rdy & ~rdy_ff;
  

  //////////////////////////////////////
  // Implement state tranisiton logic //
  /////////////////////////////////////
  always_comb
    begin
      //////////////////////
      // Default outputs //
      ////////////////////
      update_ch = 0;
	  dec_value = 0;
      nxt_state = FIRST;	  

      case (state)
        FIRST : begin
          if (rdy_rise) begin
		    update_ch = 1;
            nxt_state = SECOND;
          end
        end
		SECOND : begin		
		  if (rdy_rise) begin
		    dec_value = 1;
			nxt_state = FIRST;
		  end else
		    nxt_state = SECOND;
		end
      endcase
    end
	
  assign A2D_data = (channel==3'b000) ? {4'h0,B1} :
                    (channel==3'b001) ? {4'h0,LP} :
					(channel==3'b010) ? {4'h0,B3} :
					(channel==3'b011) ? {4'h0,HP} :
					(channel==3'b100) ? {4'h0,B2} :
					(channel==3'b111) ? {4'h0,VOL} :
					16'hxxx;

endmodule  
  