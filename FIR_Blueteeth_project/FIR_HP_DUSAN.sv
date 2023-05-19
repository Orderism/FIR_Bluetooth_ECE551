module FIR_HP(sequencing, lft_in, rght_in, lft_out, rght_out, clk, rst_n);

input sequencing, clk, rst_n;
input signed [15:0] lft_in, rght_in;
output [15:0] lft_out, rght_out;

logic clr_addr, inc_addr, accum, clr_accum;
logic [9:0] addr;
logic signed [15:0] coeff;
logic signed [31:0] lft_Scaled, rght_Scaled;
logic signed [31:0] lft_ff, rght_ff;

ROM_HP iROM_HP(.clk(clk), .addr(addr), .dout(coeff));

//ROM input logic

always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n)
	addr <= 10'd0;
else if(!clr_addr) begin
	if(inc_addr)
		addr <= addr + 10'd1; 
end
else
	addr <= 10'd0;
end

//lft_out logic

assign lft_Scaled = lft_in * coeff;
assign rght_Scaled = rght_in * coeff;
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		lft_ff <= 32'd0;
		rght_ff<=32'd0;
	end
	else if(clr_accum) begin
		lft_ff <= 32'd0;
		rght_ff<=32'd0;
	end	
	else if(accum) begin
			lft_ff <= lft_Scaled + lft_ff;	
			rght_ff<=rght_Scaled+ rght_ff;	
	end
end

assign lft_out = lft_ff[30:15];
assign rght_out = rght_ff[30:15];

//state machine

typedef enum logic {IDLE, SEQUENCING} state_t;
state_t state, next_state;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;

always_comb begin
	clr_addr = 1;
	inc_addr = 0;
	accum = 0;
	clr_accum = 0;
	next_state = state;

	case(state)

		SEQUENCING: begin
			clr_addr = 0;
			inc_addr = 1;
			accum = 1;
			if(!sequencing)
			next_state = IDLE;
		end

		//idle
		IDLE: begin	
		if(sequencing) begin
			clr_accum = 1;
			next_state = SEQUENCING; end
		end
	endcase

end

endmodule