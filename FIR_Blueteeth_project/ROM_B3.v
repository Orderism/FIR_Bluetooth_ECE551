module ROM_B3(clk,addr,dout);

input clk;				// 50MHz clock
input [9:0] addr;		// select 1 of 1024 entries
output reg [15:0] dout;	// coefficient out

  // synopsys translate_off
  reg [15:0] rom[1023:0];
  
  initial
    $readmemh("Coeff_B3_hex.txt",rom);		// Read coefficients of B3 filter
  
  always @(posedge clk)
    dout <= rom[addr];
  // synopsys translate_on

endmodule
