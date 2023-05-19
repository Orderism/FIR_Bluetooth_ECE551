module dualPort1536x16(clk,we,waddr,raddr,wdata,rdata);

  input clk;				// RAM clock.
  input we;					// active high write enable
  input [10:0] waddr;		// 11-bit write enable (0 thru 1525)
  input [10:0] raddr;		// 11-bit read enable (0 thru 1525)
  input [15:0] wdata;		// data to write
  output reg [15:0] rdata;	// data being read

  reg [15:0] mem [1535:0];

  always @(posedge clk) begin
    if (we)
      mem[waddr] <= wdata;
    rdata <= mem[raddr];
  end

endmodule
