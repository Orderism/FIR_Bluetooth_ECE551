module up_dwn_cnt4(en, dwn, cnt, clk, rst_n);
input en, clk, rst_n;
input dwn;
output wire [3:0]cnt;
reg [3:0]cnt_reg;


always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
cnt_reg<=4'd0;
end

else if (en) begin

if(~dwn)
cnt_reg<=cnt_reg+1'b1;

else 
cnt_reg<=cnt_reg-1'b1;

end

else begin
cnt_reg<=cnt_reg;
end
end



assign cnt=cnt_reg;

endmodule