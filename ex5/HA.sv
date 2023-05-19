module HA(c_out, sum, a, b);
output sum, c_out;
input a, b;
xor sum_bit(sum, a, b);
and carry_bit(c_out, a, b);
endmodule