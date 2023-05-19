module R_shifter(src, arith, amt, res);
input [15:0]src;  //in Input vector to be logically or arithmetically right shifted.
input arith;      //If arith is asserted then the right shift should be arithmetic.
input [3:0]amt;   // in Specifies the amount of the shift 0 to 15 bits
output [15:0]res; //out Result of the shift

wire [15:0] res_lg_1;
wire [15:0] res_lg_2;
wire [15:0] res_lg_4;
wire [15:0] res_lg_8;
wire [15:0] res_ar_1;
wire [15:0] res_ar_2;
wire [15:0] res_ar_4;
wire [15:0] res_ar_8;

//logic shift
assign res_lg_1= (amt[0]& ~arith)? {1'b0,src[15:1]}:src;
assign res_lg_2= (amt[1]& ~arith)? {2'b0,res_lg_1[15:2]}:res_lg_1;
assign res_lg_4= (amt[2]& ~arith)? {4'b0,res_lg_2[15:4]}:res_lg_2;
assign res_lg_8= (amt[3]& ~arith)? {8'b0,res_lg_4[15:8]}:res_lg_4;

//arith shift
assign res_ar_1= (amt[0]& arith)? {src[15],src[15:1]}:src;
assign res_ar_2= (amt[1]& arith)? {{2{res_ar_1[15]}},res_ar_1[15:2]}:res_ar_1;
assign res_ar_4= (amt[2]& arith)? {{4{res_ar_2[15]}},res_ar_2[15:4]}:res_ar_2;
assign res_ar_8= (amt[3]& arith)? {{8{res_ar_4[15]}},res_ar_4[15:8]}:res_ar_4;

assign res =(~arith)? res_lg_8:res_ar_8;
endmodule