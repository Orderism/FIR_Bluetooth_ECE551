module low_freq_queue(clk, rst_n, lft_smpl, rght_smpl, wrt_smpl, lft_out, rght_out, sequencing);

input clk, rst_n, wrt_smpl;
input [15:0] lft_smpl, rght_smpl;
output logic sequencing;
output [15:0] lft_out, rght_out;

logic full;
logic [9:0] new_ptr, old_ptr, rd_ptr, end_ptr;

dualPort1024x16 iDual_1024x16Left(.clk(clk), .we(wrt_smpl), .waddr(new_ptr) , .raddr(rd_ptr) , .wdata(lft_smpl), .rdata(lft_out));
dualPort1024x16 iDual_1024x16Right(.clk(clk), .we(wrt_smpl), .waddr(new_ptr) , .raddr(rd_ptr) , .wdata(rght_smpl), .rdata(rght_out));

typedef enum logic {IDLE, SEQUENCING} state_t;
state_t state, next_state;




//old/new ptr incrementer
always_ff @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		new_ptr  <= 10'd0;
		//old_ptr  <= 10'd0; 
		end
	else if(wrt_smpl) begin
			new_ptr <= new_ptr + 10'd1;
	end
end

//queue full flip flop
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
	full <= 0;
	else if ((&new_ptr[9:2]) & wrt_smpl)
	full <= 1;
end



always_ff @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
	old_ptr  <= 10'd0; 
	end
	else if (full & wrt_smpl) begin
	old_ptr <= old_ptr + 10'd1; 
	end
end





//ff for controlling rd_ptr
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_ptr<=10'd0;
	end
	else if(state == SEQUENCING)
		rd_ptr <= rd_ptr + 10'd1;
	else
		rd_ptr <= old_ptr;
end

assign end_ptr = old_ptr + 10'd1020; //where rd_ptr will end at

//state machine

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end

always_comb begin
next_state = state;
sequencing = 0;

case(state)

	SEQUENCING: begin
				sequencing = 1;
				if(rd_ptr == end_ptr)
					next_state = IDLE;
	end

	//IDLE
	default:  begin 
			if (wrt_smpl && full) //full and there is a sample
			next_state = SEQUENCING;
			end

endcase

end
//you are in sequencing until your read pointer (which is being incremented every clock) = old_pntr + 1020

endmodule