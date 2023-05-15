module synch_detect_tb();	

reg clk;				// system clock
reg rst_n;				// asynch reset
reg asynch_sig_in;		// models the asynchronous signal coming in

wire rise_edge;			// signal output from DUT

/////// Instantiate DUT /////////
synch_detect iDUT(.clk(clk),.rst_n(rst_n),.asynch_sig_in(asynch_sig_in),.rise_edge(rise_edge));

always begin
  clk = 0;
  rst_n = 1;
  asynch_sig_in = 1;
  @(negedge clk);
  if (rise_edge!==1'bx) begin
    $display("ERROR: rise_edge should be unknown at this time, rst_n has not been applied yet");
	$stop();
  end
  rst_n = 0;					// apply reset
  @(negedge clk);				// deassert rst_n at negedge
  rst_n = 1;
  
  @(negedge clk);
  asynch_sig_in = 0;
  repeat(2) @(posedge clk);
  if (rise_edge) begin
    $display("ERROR: triggered on falling edge instead of rising\n");
	$stop();
  end
  @(posedge clk);				// wait a clock
  @(posedge clk);
  asynch_sig_in = 1;
  @(posedge clk);
  if (rise_edge) begin
    $display("ERROR: triggering too early...did you double flop?\n");
	$stop();
  end
  @(posedge clk);
  #1;							// wait one time unit
  if (!rise_edge) begin
    $display("You should have detected rising edge here\n");
	$stop();
  end
  @(posedge clk);
  #1;							// wait one time unit
  if (rise_edge) begin
    $display("ERROR: Hmmm...should have dropped rise_edge by now\n");
    $stop();
  end
  $display("YAHOO!! all tests passed!\n");
  $stop();  
end

always
  #10 clk <= ~clk;		// toggle clock every 10 time units
  
endmodule