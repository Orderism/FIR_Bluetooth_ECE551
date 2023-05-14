module up_dwn_tb();

reg clk, rst_n;
reg en, up_dwn_n;

// Instantiate DUT //
counter iDUT(.clk(clk), .rst_n(rst_n), .en(en), .up_dwn_n(up_dwn_n));

initial begin
  clk = 0;
  rst_n = 0;				// assert reset
  en = 0;					// start with it disabled
  up_dwn_n = 1;				// count up at first
  @(posedge clk);			// wait one clock cycle
  @(negedge clk) rst_n = 1;	// deassert reset on negative edge (typically good practice)
  @(posedge clk) en= 1;		// start counting
  repeat (5)@(posedge clk);	// wait 5 clock cycles
  en = 0;					// stop counting
  @(posedge clk) en = 1;	// for 1 clock cycle
  repeat(2) @(posedge clk);	// wait 2 clock cycles
  up_dwn_n = 0;				// start counting backwards
  repeat(3) @(posedge clk);
  $stop();
end

always
  #5 clk = ~clk;

endmodule  