module PB_release(PB, clk, rst_n, released);
input logic PB;
input rst_n;////
input logic clk;//from tb
output released;

//SEQUENCIAL LOGIC
reg pre1, pre2,  pre3;
always @(negedge clk or negedge rst_n) begin

if (!rst_n) begin
pre1<=1'b0;
pre2<=1'b0;
pre3<=1'b0;
end

else begin
pre1<=PB;
pre2<=pre1;
pre3<=pre2;
end

end

assign released=(~pre3) & pre2;


endmodule