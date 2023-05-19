module tone_ROM_lft(clk,addr,dout);

input clk;				// 50MHz clock
input [11:0] addr;		// select 1 of 4096 16-bits of tone
output reg [15:0] dout;	// data byte

  reg [15:0]rom[0:4095];
  
  initial
    $readmemh("tone_hex_lft.txt",rom);		// Read tone data
  
  always @(posedge clk)
    dout <= rom[addr];

endmodule
