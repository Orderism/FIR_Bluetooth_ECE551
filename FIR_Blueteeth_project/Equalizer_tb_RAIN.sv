module Equalizer_tb();

reg clk,RST_n;
reg next_n,prev_n,Flt_n;
reg [11:0] LP,B1,B2,B3,HP,VOL;

wire [7:0] LED;
wire ADC_SS_n,ADC_MOSI,ADC_MISO,ADC_SCLK;
wire I2S_data,I2S_ws,I2S_sclk;
wire cmd_n,RX_TX,TX_RX;
wire lft_PDM,rght_PDM;
wire lft_PDM_n,rght_PDM_n;

//////////////////////
// Instantiate DUT //
////////////////////
Equalizer iDUT(.clk(clk),.RST_n(RST_n),.LED(LED),.ADC_SS_n(ADC_SS_n),
                .ADC_MOSI(ADC_MOSI),.ADC_SCLK(ADC_SCLK),.ADC_MISO(ADC_MISO),
                .I2S_data(I2S_data),.I2S_ws(I2S_ws),.I2S_sclk(I2S_sclk),.cmd_n(cmd_n),
				.sht_dwn(sht_dwn),.lft_PDM(lft_PDM),.rght_PDM(rght_PDM),
				.lft_PDM_n(lft_PDM_n),.rght_PDM_n(rght_PDM_n),.Flt_n(Flt_n),
				.next_n(next_n),.prev_n(prev_n),.RX(RX_TX),.TX(TX_RX));
	
	
//////////////////////////////////////////
// Instantiate model of RN52 BT Module //
////////////////////////////////////////	
RN52 iRN52(.clk(clk),.RST_n(RST_n),.cmd_n(cmd_n),.RX(TX_RX),.TX(RX_TX),.I2S_sclk(I2S_sclk),
           .I2S_data(I2S_data),.I2S_ws(I2S_ws));

//////////////////////////////////////////////
// Instantiate model of A2D and Slide Pots //
////////////////////////////////////////////		   
A2D_with_Pots iPOTs(.clk(clk),.rst_n(RST_n),.SS_n(ADC_SS_n),.SCLK(ADC_SCLK),.MISO(ADC_MISO),
                    .MOSI(ADC_MOSI),.LP(LP),.B1(B1),.B2(B2),.B3(B3),.HP(HP),.VOL(VOL));
					
					


initial begin



	//This is where your magic occurs
	RST_n = 1'b0;
	clk = 1'b0;
	Flt_n = 1'b1;
	prev_n = 0;
	next_n = 0;
	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'h000;
	VOL = 12'h000;
	@(negedge clk) RST_n = 1'b1;
	
	// Test with all pass bands.
	@(posedge clk);
	LP = 12'hFFF;
	B1 = 12'hFFF;
	B2 = 12'hFFF;
	B3 = 12'hFFF;
	HP = 12'hFFF;
	VOL = 12'h00F;
	repeat(2000000) @(posedge clk);

	

	// Test with only low pass.
	LP = 12'h008;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'h000;
	VOL = 12'h0FF;
	repeat(2000000) @(posedge clk);


	// Test with only B1.
	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h08F;
	HP = 12'h000;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	// Test with only B2.
	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h08F;
	B3 = 12'h000;
	HP = 12'h000;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	// Test with only B3.
	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h08F;
	HP = 12'h000;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'hFFF;
	B2 = 12'hFFF;
	B3 = 12'hFFF;
	HP = 12'hFFF;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'hFFF;
	B3 = 12'hFFF;
	HP = 12'hFFF;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'hFFF;
	HP = 12'hFFF;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'hFFF;
	VOL = 12'h08F;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'hFFF;
	VOL = 12'h800;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'hFFF;
	VOL = 12'hf00;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'h000;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'hFFF;
	VOL = 12'h400;
	repeat(2000000) @(posedge clk);
		$stop;

	LP = 12'hFFF;
	B1 = 12'h000;
	B2 = 12'h000;
	B3 = 12'h000;
	HP = 12'h000;
	VOL = 12'h008;
	repeat(2000000) @(posedge clk);
	$display("Finished runnning test values.");
	$stop;
	$finish;
	
end


always
  #5 clk = ~ clk;
  
endmodule	  