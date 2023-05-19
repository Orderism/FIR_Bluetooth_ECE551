module ROM(clk,addr,dout);

  input clk;
  input [9:0] addr;
  output reg [15:0] dout;
  
  reg [15:0]mem[0:1023];
  
  initial
    $readmemh("sin_table.hex",mem);
	
  always @(posedge clk)
    dout <= mem[addr];

endmodule
