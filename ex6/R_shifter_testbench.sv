module R_shifter_testbench();
reg [15:0]src;  
reg arith;      
reg [3:0]amt;   
wire [15:0]res;

R_shifter rs(.src(src),.amt(amt),.arith(arith),.res(res));

initial begin
#10;
src[15:0]=16'd0;
arith=1'd0;
amt=4'd0;

#10;
src[15:0]=16'b1010_1111_1011_1000;
arith=1'd1;
amt=4'd6;

#10;
src[15:0]=16'b1010_1111_1011_1000;
arith=1'd0;
amt=4'd13;
end


endmodule


 