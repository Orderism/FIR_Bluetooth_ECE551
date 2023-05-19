module resp_ROM(clk,addr,dout);

input clk;				// 50MHz clock
input [3:0] addr;		// select 1 of 16 bytes of command
output reg [7:0] dout;	// data byte

  reg [7:0] rom[0:15];
  
  initial
    $readmemh("resp_hex.txt",rom);		// Read command encodings
  
  always @(posedge clk)
    dout <= rom[addr];

endmodule
