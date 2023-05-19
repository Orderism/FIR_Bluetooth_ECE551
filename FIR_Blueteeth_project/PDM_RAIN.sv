module PDM(clk, rst_n, duty, PDM, PDM_n);
input clk, rst_n;
input [15:0]duty;
output PDM, PDM_n;


reg [15:0]A1,B;
reg [15:0]f1,f2;
reg [15:0] B_branch;
wire sel;
reg PDM_reg, PDM_n_reg;

//Sequential logic
//the sequential logic part include as follow:
//#1.duty to A1
//#2.f2 to B_branch
//#3.B_branch to PDM
//#4.B_branch to PDM_n

always @(posedge clk or negedge rst_n) begin

if (!rst_n) begin
A1<=16'd0;
B<=16'd0;//for the output of mux 2
PDM_reg<=1'd0;
//PDM_n_reg<=16'd0;
f1<=16'd0;
f2<=16'd0;
B_branch<=16'd0;
end

else begin
A1<=duty;//#1
B<=(sel)? 16'hffff: 16'd0;
f1<=B-A1;
f2<=f1+B_branch;
B_branch<=f2;//#2
PDM_reg<= ((A1==B_branch) | (A1>B_branch))? 1'b1:1'b0;//#3
//PDM_n_reg<=~PDM_reg;//#4
end
end

assign sel=(A1>=B_branch)?1'b1:1'b0;
assign PDM=PDM_reg;
assign PDM_n=~PDM;

endmodule

/*
module PDM(clk, rst_n, duty, PDM, PDM_n);

	input clk, rst_n;
	input [15:0] duty;
	
	reg update;
	wire unsigned [15:0] out1, out2;

	reg [15:0] duty_out, out3;
	
	output PDM, PDM_n;
	
	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			duty_out = 16'h0000;
		else 
			if (update)
				duty_out = duty + 16'h8000;
	end

	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			update = 1'b0;
		else
			update = ~update;
	end

	assign out1 = ((PDM ? 16'hffff : 16'h0000) - duty_out);
	assign out2 = out1 + out3;
	
	always @(posedge clk, negedge rst_n)
	begin
		if (!rst_n)
			out3 = 16'h0000;
		else 
			if (update)
				out3 = out2;
	end

	assign PDM = (duty_out >= out3) ? 1'b1 : 1'b0;
    assign PDM_n = ~PDM;
	
endmodule
	*/
	
	