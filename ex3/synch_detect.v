module synch_detect(asynch_sig_in, clk, rise_edge, rst_n);
input asynch_sig_in;
input  clk;
output wire rise_edge;
input rst_n;

reg asynch_sig_in_prev1;
reg asynch_sig_in_prev2;
reg rise_edge_reg;



always @(negedge clk or negedge rst_n) begin

if (!rst_n) begin
asynch_sig_in_prev1<='d1;
asynch_sig_in_prev2<='d1;
rise_edge_reg<='d0;

end

//if we have got the rise_edge, remain one cycle
else if (rise_edge=='d1) begin
asynch_sig_in_prev1<=asynch_sig_in;
asynch_sig_in_prev2<=asynch_sig_in_prev1;
rise_edge_reg<='d0;
end

//rise_edge Logic
else begin
asynch_sig_in_prev1<=asynch_sig_in;
asynch_sig_in_prev2<=asynch_sig_in_prev1;
rise_edge_reg<=((~asynch_sig_in_prev2)&&(asynch_sig_in_prev1));//LOGIC previous signal '0' and current signal '1'
end

end

assign rise_edge=rise_edge_reg;
endmodule