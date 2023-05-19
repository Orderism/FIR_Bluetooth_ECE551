module cmdROM(clk,addr,dout);

input clk;				// 50MHz clock
input [4:0] addr;		// select 1 of 32 bytes of command
output reg [7:0] dout;	// data byte

  // synopsys translate_off
  reg [7:0] rom[0:31];
  
  initial
    $readmemh("cmd_hex.txt",rom);		// Read command encodings
  
  always @(posedge clk)
    dout <= rom[addr];

  // synopsys translate_on

endmodule
