module rst_synch(RST_n, clk, rst_n);

input wire clk, RST_n;
output reg rst_n;
reg FF2in;

always @ (posedge clk, negedge RST_n)
	if(!RST_n) begin
		FF2in <= 1'b0;
		rst_n <= 1'b0;
	end
	else begin
		rst_n <= FF2in;
		FF2in <= 1'b1;
	end

endmodule

