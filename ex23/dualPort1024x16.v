
module dualPort1024x16(clk,we,waddr,raddr,wdata,rdata);

  input clk;				// RAM clock.
  input we;					// active high write enable
  input [9:0] waddr;		// 10-bit write enable (0 thru 1023)
  input [9:0] raddr;		// 10-bit read enable (0 thru 1023)
  input [15:0] wdata;		// data to write
  output reg [15:0] rdata;	// data being read

  // synopsys translate_off
  reg [15:0] mem [1023:0];

  always @(posedge clk) begin
    if (we)
      mem[waddr] <= wdata;
    rdata <= mem[raddr];
  end
  // synopsys translate_on

endmodule
