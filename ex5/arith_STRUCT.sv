module arith_STRUCT (A, B, SUB, SUM, OV);

input reg [7:0]A, B;
input SUB;
output [7:0]SUM;
output OV;

wire [7:0]B_comp1, B_comp2, B_f, B_ov;
//SUB LOGIC IN B
assign B_comp1=~B;
assign B_comp2=B_comp1+8'b00000001;
assign B_f=(SUB)? B_comp2 : B;//B_final is the B after sub signal
assign B_ov=(SUB) ? ~B : B;//for overflow logic
//FULLADDER
add8bit abc(.cout(), .sum(SUM), .a(A), .b(B_f), .cin(8'd0), .ov(OV), .B_ov(B_ov));//both cin and cout won't be connect, we just use the overflow signal as an result

endmodule