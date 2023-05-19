module FA(c_out, sum, a, b, c_in) ;
output sum, c_out;
input a, b, c_in;
wire w1, w2, w3;
HA AH1(.sum(w1), .c_out(w2), .a(a), .b(b));
HA AH2(.sum(sum), .c_out(w3), .a(c_in), .b(w1));
or carry_bit(c_out, w2, w3);
endmodule