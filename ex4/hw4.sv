
module hw4(d, clk, q);
input d;
input clk;
output q;

wire md;
wire mq;
wire sd;


assign md=(clk)? ~d:md;
assign mq=~md;
assign sd=(~clk)? ~mq:sd;
assign q=~sd;
endmodule