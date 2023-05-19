module rst_synch(RST_n, rst_n, clk);
input wire RST_n;
input wire clk;
output wire rst_n;
reg temp;//the signal between 2 ff
reg rst_n_reg;

always@(negedge clk or negedge RST_n) begin
if (!RST_n) begin
rst_n_reg <= 1'b0;
temp <= 1'b0;
end

else begin 
temp <= 1'b1;
rst_n_reg <= temp;
end

end
assign rst_n=rst_n_reg;
endmodule