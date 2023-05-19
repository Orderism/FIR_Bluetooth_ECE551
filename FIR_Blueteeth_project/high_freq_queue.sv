module high_freq_queue(clk, rst_n, lft_smpl, rght_smpl, wrt_smpl, lft_out, rght_out, sequencing);

input clk, rst_n, wrt_smpl;
input [15:0] lft_smpl, rght_smpl;
output logic sequencing;
output [15:0] lft_out, rght_out;

logic full;
logic [10:0] new_ptr, old_ptr, rd_ptr;
logic [11:0] end_ptr;

dualPort1536x16 iDual_1536x16Left(.clk(clk), .we(wrt_smpl), .waddr(new_ptr) , .raddr(rd_ptr) , .wdata(lft_smpl), .rdata(lft_out));
dualPort1536x16 iDual_1536x16Right(.clk(clk), .we(wrt_smpl), .waddr(new_ptr) , .raddr(rd_ptr) , .wdata(rght_smpl), .rdata(rght_out));
//new_ptr==11'd1530==> (new_ptr[10] & (&new_ptr[8:3]) & new_ptr[1])

//==11'd1535==> (new_ptr[10] & (&new_ptr[8:0])


typedef enum logic {IDLE, SEQUENCING} state_t;
state_t state, next_state;

//queue full flip flop
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
	full <= 0;
	else if((new_ptr[10] & (&new_ptr[8:3]) & new_ptr[1]) && wrt_smpl) 
	full <= 1;
end

//old/new ptr incrementer
always_ff @(posedge clk, negedge rst_n)begin
	if(!rst_n) begin
		new_ptr <= 11'd0;
		//old_ptr <= 11'd0; 
		end

	/*else if(full && wrt_smpl) begin //have to force rollover
		if(new_ptr[11] & (&new_ptr[8:0]))
			new_ptr <= 11'd0;
		else
			new_ptr <= new_ptr + 11'd1;
		end*/

	else if(wrt_smpl) begin
		if(new_ptr[10] & (&new_ptr[8:0]))
			new_ptr <= 11'd0;
		else
			new_ptr <= new_ptr + 11'd1;
		end
end


//
always @(posedge clk, negedge rst_n)begin
	if(!rst_n) begin
		old_ptr <= 11'd0; end
	else if(full && wrt_smpl) begin //have to force rollover

		if(old_ptr[10] & (&old_ptr[8:0]))
			old_ptr <= 11'd0;
		else
			old_ptr <= old_ptr + 11'd1; 
		end
end







//ff for controlling rd_ptr
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr<='d0;
	end
	else if(state == SEQUENCING) begin
		if(rd_ptr[10] & (&rd_ptr[8:0]))
			rd_ptr <= 11'd0;
		else
			rd_ptr <= rd_ptr + 11'd1;
	end
	else
		rd_ptr <= old_ptr;
end
//state machine
//output signal: sequencing
//making sure to rap around 1535 when read needs to go past
//for old pointer
logic [11:0] A,B;
assign A=old_ptr + 11'd1020;
assign B=old_ptr - 11'd516;


assign end_ptr = (old_ptr <= 11'd515) ? A: B; // + 1020 - 1536);

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

	IDLE: begin
		if(wrt_smpl && full) //full and there is a sample
		next_state = SEQUENCING;
	end

endcase

end
//you are in sequencing until your read pointer (which is being incremented every clock) = old_pntr + 1020
//(make sure to have combinational logic to take care of wrapping around boundary)

endmodule