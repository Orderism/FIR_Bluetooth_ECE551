module EQ_engine(
//input
input wire  signed  [15:0] aud_in_lft,
input wire signed [15:0] aud_in_rght,
input logic vld,
input logic clk, 
input logic rst_n,
input logic unsigned [11:0]POT_B1, POT_B2, POT_B3, POT_HP, POT_LP,
input logic unsigned [11:0]POT_VOL,
//output
output  logic [15:0] aud_out_lft, aud_out_rght
);
logic [9:0] new_ptr, old_ptr, rd_ptr, end_ptr;
logic lf_vld;




/////vld cnter, 2hf_vld=1lf_vld////
//need a shifter for the low frequency wrt_smpl

logic vld_cnt;

always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
		 vld_cnt<=0;
		 lf_vld<=0;
		end
		else if(vld) begin
		 	if(vld_cnt) begin
			vld_cnt<=0;
			lf_vld<=1;
			end
			else begin//if high freq valid asserted 2 times, lf_vld asserted 1 time
			vld_cnt<=vld_cnt+1'd1;
			lf_vld<=0;
			end
		end
		else begin
			lf_vld<=0;
		end
end


////queue module////
logic sequencing_lf, sequencing_hf;
logic [15:0]lft_out_hf_q,lft_out_lf_q;//lf and hf output from the queue ,'q'
logic [15:0]rght_out_hf_q,rght_out_lf_q;
high_freq_queue	hfq_engine(.clk(clk), .rst_n(rst_n), .lft_smpl(aud_in_lft), .rght_smpl(aud_in_rght), .wrt_smpl(vld), .lft_out(lft_out_hf_q), .rght_out(rght_out_hf_q), .sequencing(sequencing_hf));
low_freq_queue lfq_engine(.clk(clk), .rst_n(rst_n), .lft_smpl(aud_in_lft), .rght_smpl(aud_in_rght), .wrt_smpl(lf_vld), .lft_out(lft_out_lf_q), .rght_out(rght_out_lf_q), .sequencing(sequencing_lf));

//FF FOR delay 1 clk
//enhance the driver ability of the local clk
//assign clk2=~clk;

/*
//ONE ff for the timing requirement, split the work into 2 cycles

logic sequencing_lf_dl1, sequencing_hf_dl1;
logic [15:0]lft_out_hf_q_dl1,lft_out_lf_q_dl1;//lf and hf output from the queue ,'q'
logic [15:0]rght_out_hf_q_dl1,rght_out_lf_q_dl1;


always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		sequencing_hf_dl1<=0;
		sequencing_hf_dl1<=0;
		lft_out_hf_q_dl1<=16'd0;
		lft_out_lf_q_dl1<=16'd0;
		rght_out_hf_q_dl1<=16'd0;
		rght_out_lf_q_dl1<=16'd0;
	end
	else begin
		sequencing_hf_dl1<=sequencing_hf;
		sequencing_lf_dl1<=sequencing_lf;
		lft_out_hf_q_dl1<=lft_out_hf_q;
		lft_out_lf_q_dl1<=lft_out_lf_q;
		rght_out_hf_q_dl1<=rght_out_hf_q;
		rght_out_lf_q_dl1<=rght_out_lf_q;
	
	end
end
this is not in the critical path, it only increasing the delay
*/









////FIR module////
//FIR_LP, FIR_B1 connect with lf parts
logic [15:0]lft_out_LP,rght_out_LP;//lf and hf output from the FIR, with different chnnl name as end
logic [15:0]lft_out_B1,rght_out_B1;
FIR_LP FIR_LP(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_lf_q), .rght_in(rght_out_lf_q), .lft_out(lft_out_LP), .rght_out(rght_out_LP));
FIR_B1 FIR_B1(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_lf_q), .rght_in(rght_out_lf_q), .lft_out(lft_out_B1), .rght_out(rght_out_B1));
//FIR_B2, FIR_B3, FIR_HP connect with Hf parts
logic [15:0]lft_out_B2,rght_out_B2;
logic [15:0]lft_out_B3,rght_out_B3;
logic [15:0]lft_out_HP,rght_out_HP;
FIR_B2 FIR_B2(.sequencing(sequencing_hf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_hf_q), .rght_in(rght_out_hf_q), .lft_out(lft_out_B2), .rght_out(rght_out_B2));
FIR_B3 FIR_B3(.sequencing(sequencing_hf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_hf_q), .rght_in(rght_out_hf_q), .lft_out(lft_out_B3), .rght_out(rght_out_B3));
FIR_HP FIR_HP(.sequencing(sequencing_hf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_hf_q), .rght_in(rght_out_hf_q), .lft_out(lft_out_HP), .rght_out(rght_out_HP));




//////////delayff///////////////////////
logic [15:0]lft_out_LP_dl1,rght_out_LP_dl1;//
logic [15:0]lft_out_B1_dl1,rght_out_B1_dl1;

logic [15:0]lft_out_B2_dl1,rght_out_B2_dl1;
logic [15:0]lft_out_B3_dl1,rght_out_B3_dl1;
logic [15:0]lft_out_HP_dl1,rght_out_HP_dl1;

logic unsigned [11:0]POT_B1_dl1, POT_B2_dl1, POT_B3_dl1, POT_HP_dl1, POT_LP_dl1;
logic unsigned [11:0]POT_VOL_dl1;


//FOr this part need to delay the POT_signal, so all the input to next stage need to be delay1
//after multiple inproved, the setup offset is 0.98, with this part, it will be 1.07
always @(posedge clk) begin
	if(!rst_n) begin
		lft_out_LP_dl1<=16'd0;
		rght_out_LP_dl1<=16'd0;
		lft_out_B1_dl1<=16'd0;
		rght_out_B1_dl1<=16'd0;
		lft_out_B2_dl1<=16'd0;
		rght_out_B2_dl1<=16'd0;
		lft_out_B3_dl1<=16'd0;
		rght_out_B3_dl1<=16'd0;
		lft_out_HP_dl1<=16'd0;
		rght_out_HP_dl1<=16'd0;
		//
		POT_LP_dl1<=12'd0;
		POT_B1_dl1<=12'd0;
		POT_B2_dl1<=12'd0;
		POT_B3_dl1<=12'd0;
		POT_HP_dl1<=12'd0;
		POT_VOL_dl1<=12'd0;
	end



	else begin

		lft_out_LP_dl1<=lft_out_LP;
		rght_out_LP_dl1<=rght_out_LP;
		lft_out_B1_dl1<=lft_out_B1;
		rght_out_B1_dl1<=rght_out_B1;
		lft_out_B2_dl1<=lft_out_B2;
		rght_out_B2_dl1<=rght_out_B2;
		lft_out_B3_dl1<=lft_out_B3;
		rght_out_B3_dl1<=rght_out_B3;
		lft_out_HP_dl1<=lft_out_HP;
		rght_out_HP_dl1<=rght_out_HP;
		//
		POT_LP_dl1<=POT_LP;
		POT_B1_dl1<=POT_B1;
		POT_B2_dl1<=POT_B2;
		POT_B3_dl1<=POT_B3;
		POT_HP_dl1<=POT_HP;
		POT_VOL_dl1<=POT_VOL;
	end
end

//////////delayff///////////////////////

//////bandscale module ////
logic [15:0]lft_LP_sc, rght_LP_sc;//scaled audio signal
logic [15:0]lft_B1_sc, rght_B1_sc;
logic [15:0]lft_B2_sc, rght_B2_sc;
logic [15:0]lft_B3_sc, rght_B3_sc;
logic [15:0]lft_HP_sc, rght_HP_sc;
// band_scale band_scale(.POT(POT_LP)12BITS, .audio(lft_out_LP)16BITS, scaled(lft_LP_sc)16BITS);
//lft scaling
band_scale band_scale_lft_LP(.POT(POT_LP_dl1), .audio(lft_out_LP_dl1), .scaled(lft_LP_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_lft_B1(.POT(POT_B1_dl1), .audio(lft_out_B1_dl1), .scaled(lft_B1_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_lft_B2(.POT(POT_B2_dl1), .audio(lft_out_B2_dl1), .scaled(lft_B2_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_lft_B3(.POT(POT_B3_dl1), .audio(lft_out_B3_dl1), .scaled(lft_B3_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_lft_HP(.POT(POT_HP_dl1), .audio(lft_out_HP_dl1), .scaled(lft_HP_sc), .clk(clk), .rst_n(rst_n));
//rght scaling
band_scale band_scale_rght_LP(.POT(POT_LP_dl1), .audio(rght_out_LP_dl1), .scaled(rght_LP_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_rght_B1(.POT(POT_B1_dl1), .audio(rght_out_B1_dl1), .scaled(rght_B1_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_rght_B2(.POT(POT_B2_dl1), .audio(rght_out_B2_dl1), .scaled(rght_B2_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_rght_B3(.POT(POT_B3_dl1), .audio(rght_out_B3_dl1), .scaled(rght_B3_sc), .clk(clk), .rst_n(rst_n));
band_scale band_scale_rght_HP(.POT(POT_HP_dl1), .audio(rght_out_HP_dl1), .scaled(rght_HP_sc), .clk(clk), .rst_n(rst_n));



//Sum 

logic signed [15:0]  A,B,C,D;//temp variale to reduce the aera
assign A=lft_LP_sc + lft_B1_sc;
assign B=lft_B2_sc + lft_B3_sc + lft_HP_sc;
assign C=rght_LP_sc + rght_B1_sc;
assign D=rght_B2_sc + rght_B3_sc + rght_HP_sc;








//R2 for the sum result from the hf/lf
logic signed [15:0] lft_sum_reg, rght_sum_reg;
always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			lft_sum_reg<=16'd0;
			lft_sum_reg<=16'd0;
		end
		
		else begin
			lft_sum_reg<=A+B;
			rght_sum_reg<=C+D;
		end
end



//multiplier
logic signed [28:0] lft_mult_result, rght_mult_result;
logic signed [12:0]POT_VOL_ext;
assign POT_VOL_ext={1'b0,POT_VOL};
assign lft_mult_result=lft_sum_reg* POT_VOL_ext;
assign rght_mult_result=rght_sum_reg* POT_VOL_ext;

//out put
assign aud_out_lft=lft_mult_result[27:12];
assign aud_out_rght=rght_mult_result[27:12];

endmodule