module dualPort1024x16(w_data, r_data, waddr, raddr, clk, rst_n, we);
input wire [15:0] w_data;
output wire [15:0] r_data;
input clk, rst_n;
input [9:0] waddr, raddr;
input we;
reg [15:0]mem[0:1023];
reg [15:0]r_data_reg;

always @(posedge clk) begin
  if (we)
     mem[waddr]<=w_data;
  r_data_reg<=mem[raddr];
end


assign r_data=r_data_reg;

endmodule

