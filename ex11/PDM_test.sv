module PDM_test(clk,RST_n,PB,LED, LEDcnt);

	input clk;		// our 50MHz clock from DE0-Nano
	input RST_n;	// from push button, goes to our rst_synch block
	input PB;		// from push button, goes to our PB_release detector
	

	output [7:0] LED;
        output [3:0] LEDcnt;

		// LED[0] intensity controlled by PDM
							// LED[7:4] provide observability of our 4-bit counter

	////////////////////////////////////////
	// Declare any internal signals here //
	//////////////////////////////////////
	wire rst_n;			// global reset to all other blocks, produced by rst_synch
	wire btn_release;	// from PB_release unit, goes high 1 clock with button release
	wire [3:0] cnt;		// used to hook to output of up/dwn counter
	wire [15:0] duty;	// upper 4-bit from your counter, lower 12-bits all zero
	wire nxt_dwn;		// output of combinational logic that determines up vs dwn
	wire PDM,PDM_n;
	
	//////////////////////////////////////////////////////////////
	// Next is declaration of flop that will form the dwn that //
	// determines if 4-bit counter is counting up or down     //
	///////////////////////////////////////////////////////////
	reg dwn;

	/////////////////////////////////////
	// Instantiate reset synchronizer //
	///////////////////////////////////
	rst_synch iRST(.RST_n(RST_n), .clk(clk), .rst_n(rst_n));

	///////////////////////////////////////////////
	// Instantiate push button release detector //
	/////////////////////////////////////////////
	PB_release iPB(.clk(clk), .rst_n(rst_n), .PB(PB), .released(btn_release));
	
	//////////////////////////////////////////
	// Always block to infer dwn flip flop //
	////////////////////////////////////////
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    dwn <= 0;
	  else
	    dwn <= nxt_dwn;
		
	assign nxt_dwn = (cnt==4'b1111 && ~dwn)? ~dwn:
                         (cnt==4'b0000 && dwn) ? ~dwn:
                         dwn;

	/////////////////////////////////////////////////
	// Instantiation of your 4-bit up/dwn counter //
    ///////////////////////////////////////////////
	up_dwn_cnt4 iCNT(.clk(clk), .rst_n(rst_n), .en(btn_release), .dwn(dwn), .cnt(cnt));
	
    ///////////////////////////////////////////////////////////
	// assign duty to {cnt,zeros}...forms duty input to PDM //
	/////////////////////////////////////////////////////////
	assign duty = {cnt, 12'd0};
	
	/////////////////////////////////////////
	// Instantiate PDM (which is the DUT) //
	///////////////////////////////////////
	PDM iDUT(.clk(clk), .rst_n(rst_n), .duty(duty), .PDM(PDM), .PDM_n(PDM_n));
	
	/////////////////////////////////////////////////
	// MS 4-bits is cnt for observability, lowest //
	// LED varies in intensity with duty cycle   //
	//////////////////////////////////////////////
	assign LED = {cnt,1'b0,PDM_n,1'b0,PDM};
assign LEDcnt=LED[7:4];
	
endmodule

