module Equalizer(clk,RST_n,LED,ADC_SS_n,ADC_MOSI,ADC_SCLK,ADC_MISO,
                 I2S_data,I2S_ws,I2S_sclk,cmd_n,sht_dwn,lft_PDM,
				 rght_PDM,lft_PDM_n,rght_PDM_n,Flt_n,next_n,
				 prev_n,RX,TX);
				  
    input clk;			// 50MHz CLOCK
	input RST_n;		// unsynched active low reset from push button
	output [7:0] LED;   // Extra credit opportunity, otherwise tie low
	output ADC_SS_n;	// Next 4 are SPI interface to A2D
	output ADC_MOSI;
	output ADC_SCLK;
	input ADC_MISO;
	input I2S_data;		// serial data line from BT audio
	input I2S_ws;		// word select line from BT audio
	input I2S_sclk;		// clock line from BT audio
	output cmd_n;		// hold low to put BT module in command mode
	output reg sht_dwn;	// hold high until low freq queues full
	output lft_PDM;	    // Duty cycle of this drives left speaker
	output rght_PDM;	// Duty cycle of this drives right speaker
	output lft_PDM_n;   // Inverted PDM for differential drive
	output rght_PDM_n;  // Inverted PDM for differential drive
	input Flt_n;		// when low Amp(s) had a fault and need shtdwn
	input next_n;		// active low to skip to next song
	input prev_n;		// active low to repeat previous song
	input RX;			// UART RX (115200) from BT audio module
	output TX;			// UART TX to BT audio module

    /////////////////////////////////////////////////////
	// Declare wires for internal connection of units //
	///////////////////////////////////////////////////
	wire [11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;
	wire signed [23:0] lft_chnnl_in, rght_chnnl_in;
	wire signed [15:0] lft_chnnl_out, rght_chnnl_out;
	wire vld, seq_low;
	

	  
	//assign LED = {8'h00};

		 

	/////////////////////////////////////
	// Instantiate Reset synchronizer //
	///////////////////////////////////
	rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));


	//////////////////////////////////////
	// Instantiate Slide Pot Interface //
	////////////////////////////////////					
	slide_intf iSLD(.clk(clk),.rst_n(rst_n),.SS_n(ADC_SS_n),.MOSI(ADC_MOSI),.MISO(ADC_MISO),
	                .SCLK(ADC_SCLK),.POT_LP(POT_LP),.POT_B1(POT_B1),.POT_B2(POT_B2),
					.POT_B3(POT_B3),.POT_HP(POT_HP),.VOLUME(VOLUME));
				  
	//////////////////////////////////////
	// Instantiate BT module interface //
	////////////////////////////////////
	bt_intf iBT(.clk(clk),.rst_n(rst_n),.next_n(next_n),.prev_n(prev_n),
	            .RX(RX),.TX(TX), .cmd_n(cmd_n));
					
			
    //////////////////////////////////////
    // Instantiate I2S_Slave interface //
    ////////////////////////////////////
	I2S_Serf iI2S(.clk(clk),.rst_n(rst_n),.I2S_sclk(I2S_sclk),.I2S_data(I2S_data),
	               .I2S_ws(I2S_ws),.lft_chnnl(lft_chnnl_in),.rght_chnnl(rght_chnnl_in),
				   .vld(vld));

    /////////////////////////////////////////////////
    // Instantiate Equalizer Engine or equivalent //
    ///////////////////////////////////////////////	
	EQ_engine iEQ(.clk(clk),.rst_n(rst_n),.VOLUME(VOLUME),.POT_LP(POT_LP),
	              .POT_B1(POT_B1),.POT_B2(POT_B2),.POT_B3(POT_B3),.POT_HP(POT_HP),
			      .aud_in_lft(lft_chnnl_in[23:8]),.aud_out_lft(lft_chnnl_out),
			      .aud_in_rht(rght_chnnl_in[23:8]),.aud_out_rht(rght_chnnl_out),
			      .vld(vld),.seq_low(seq_low));
				  
	LED	iLED(.clk(clk),.rst_n(rst_n),.lft(lft_chnnl_out),.rht(rght_chnnl_out),.LED(LED));

	/////////////////////////////////////
	// Instantiate PDM speaker driver //
	///////////////////////////////////
	spkr_drv iDRV(.clk(clk),.rst_n(rst_n),.vld(vld),.lft_chnnl(lft_chnnl_out),
	              .rght_chnnl(rght_chnnl_out),.lft_PDM(lft_PDM),.rght_PDM(rght_PDM),
				  .lft_PDM_n(lft_PDM_n),.rght_PDM_n(rght_PDM_n));
				  
	///////////////////////////////////////////////////////////////
	// Infer sht_dwn/Flt_n logic or incorporate into other unit //
	/////////////////////////////////////////////////////////////
	


endmodule
