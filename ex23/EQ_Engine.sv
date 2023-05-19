module EQ_engine(

//input
input logic [15:0]audio_in_lft, audio_in_rght,
input logic vld,
input logic clk, rst_n,
input logic [11:0]POT_B1, POT_B2, POT_B3, POT_HP, POT_LP,
input logic [11:0]POT_VOL,
//output
output  logic [15:0] aud_out_lft, aud_out_rght
);

/////vld cnter, 2hf_vld=1lf_vld////
//need a shifter for the low frequency wrt_smpl
logic lf_vld, hf_vld, vld_cnt;
assign hf_vld=vld;
always @(posedge clk, negedge rst_n) begin
		if(!rst_n) 
		 vld_cnt<=0;
		if(vld_cnt) begin
			vld_cnt<=0;
			lf_vld<=1;
		end
		else if(hf_vld) begin//if high freq valid asserted 2 times, lf_vld asserted 1 time
			vld_cnt<=vld_cnt+1;
			lf_vld<=0;
		end
		 else begin
			vld_cnt<=vld_cnt;
			lf_vld<=lf_vld;
		end
end
//logic of the  queue input write enable signal
assign wrt_smp_lf= lf_vld & hf_vld;
assign wrt_smp_hf= hf_vld;



////queue module////
logic sequencing_lf, sequencing_hf;
logic lft_out_hf_q,lft_out_lf_q;//lf and hf output from the queue ,'q'
logic rght_out_hf_q,rght_out_lf_q;
high_freq_queue	hfq_EQ_engine(.clk(clk), .rst_n(rst_n), .lft_smpl(audio_in_lft), .rght_smpl(audio_in_rght), .wrt_smpl(wrt_smp_hf), .lft_out(lft_out_hf_q), .rght_out(rght_out_hf_q), .sequencing(sequencing_hf));
low_freq_queue lfq_EQ_engine(.clk(clk), .rst_n(rst_n), .lft_smpl(audio_in_lft), .rght_smpl(audio_in_rght), .wrt_smpl(wrt_smp_lf), .lft_out(lft_out_lf_q), .rght_out(rght_out_lf_q), .sequencing(sequencing_lf));



////FIR module////
//FIR_LP, FIR_B1 connect with lf parts
logic [15:0]lft_out_LP,rght_out_LP;//lf and hf output from the FIR, with different chnnl name as end
logic [15:0]lft_out_B1,rght_out_B1;
FIR FIR_LP(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_lf_q), .rght_in(rght_out_lf_q), .lft_out(lft_out_LP), .rght_out(rght_out_LP));
FIR FIR_B1(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_lf_q), .rght_in(rght_out_lf_q), .lft_out(lft_out_B1), .rght_out(rght_out_B1));
//FIR_B2, FIR_B3, FIR_HP connect with lf parts
logic [15:0]lft_out_B2,rght_out_B2;
logic [15:0]lft_out_B3,rght_out_B3;
logic [15:0]lft_out_HP,rght_out_HP;
FIR FIR_B2(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_hf_q), .rght_in(rght_out_hf_q), .lft_out(lft_out_B2), .rght_out(rght_out_B2));
FIR FIR_B3(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_hf_q), .rght_in(rght_out_hf_q), .lft_out(lft_out_B3), .rght_out(rght_out_B3));
FIR FIR_HP(.sequencing(sequencing_lf), .clk(clk), .rst_n(rst_n), .lft_in(lft_out_hf_q), .rght_in(rght_out_hf_q), .lft_out(lft_out_HF), .rght_out(rght_out_HF));



//////bandscale module ////
logic [15:0]lft_LP_sc, rght_LP_sc;//scaled audio signal
logic [15:0]lft_B1_sc, rght_B1_sc;
logic [15:0]lft_B2_sc, rght_B2_sc;
logic [15:0]lft_B3_sc, rght_B3_sc;
logic [15:0]lft_HP_sc, rght_HP_sc;
// band_scale band_scale(.POT(POT_LP)12BITS, .audio(lft_out_LP)16BITS, scaled(lft_LP_sc)16BITS);
//lft scaling
band_scale band_scale_lft_LP(.POT(POT_LP), .audio(lft_out_LP), .scaled(lft_LP_sc));
band_scale band_scale_lft_B1(.POT(POT_B1), .audio(lft_out_B1), .scaled(lft_B1_sc));
band_scale band_scale_lft_B2(.POT(POT_B2), .audio(lft_out_B2), .scaled(lft_B2_sc));
band_scale band_scale_lft_B3(.POT(POT_B3), .audio(lft_out_B3), .scaled(lft_B3_sc));
band_scale band_scale_lft_HP(.POT(POT_HP), .audio(lft_out_HP), .scaled(lft_HP_sc));
//rght scaling
band_scale band_scale_rght_LP(.POT(POT_LP), .audio(rght_out_LP), .scaled(rght_LP_sc));
band_scale band_scale_rght_B1(.POT(POT_B1), .audio(rght_out_B1), .scaled(rght_B1_sc));
band_scale band_scale_rght_B2(.POT(POT_B2), .audio(rght_out_B2), .scaled(rght_B2_sc));
band_scale band_scale_rght_B3(.POT(POT_B3), .audio(rght_out_B3), .scaled(rght_B3_sc));
band_scale band_scale_rght_HP(.POT(POT_HP), .audio(rght_out_HP), .scaled(rght_HP_sc));



//R1 for the bandscale result
logic [15:0]lft_LP_sc_reg, rght_LP_sc_reg;//scaled audio signal after register
logic [15:0]lft_B1_sc_reg, rght_B1_sc_reg;
logic [15:0]lft_B2_sc_reg, rght_B2_sc_reg;
logic [15:0]lft_B3_sc_reg, rght_B3_sc_reg;
logic [15:0]lft_HP_sc_reg, rght_HP_sc_reg;

always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			lft_LP_sc_reg<=16'd0;
			rght_LP_sc_reg<=16'd0;
			lft_B1_sc_reg<=16'd0;
			rght_B1_sc_reg<=16'd0;
			lft_B2_sc_reg<=16'd0;
			rght_B2_sc_reg<=16'd0;
			lft_B3_sc_reg<=16'd0;
			rght_B3_sc_reg<=16'd0;
			lft_HP_sc_reg<=16'd0;
			rght_HP_sc_reg<=16'd0;
		end
		
		else begin
			lft_LP_sc_reg<=lft_LP_sc;
			rght_LP_sc_reg<=rght_LP_sc;
			lft_B1_sc_reg<=lft_B1_sc;
			rght_B1_sc_reg<=rght_B1_sc;
			lft_B2_sc_reg<=lft_B2_sc;
			rght_B2_sc_reg<=rght_B2_sc;
			lft_B3_sc_reg<=lft_B3_sc;
			rght_B3_sc_reg<=rght_B3_sc;
			lft_HP_sc_reg<=lft_HP_sc;
			rght_HP_sc_reg<=rght_HP_sc;
		end
end


//Sum 
logic [15:0] lft_sum, rght_sum;

logic [15:0]A,B,C,D;//temp variale to reduce the aera
assign A=lft_LP_sc_reg + lft_B1_sc_reg;
assign B=lft_B2_sc_reg + lft_B3_sc_reg + lft_HP_sc_reg;
assign C=rght_LP_sc_reg + rght_B1_sc_reg;
assign D=rght_B2_sc_reg + rght_B3_sc_reg + rght_HP_sc_reg;
assign lft_sum=A + B;
assign rght_sum=C + D;








//R2 for the sum result from the hf/lf
logic [15:0] lft_sum_reg, rght_sum_reg;
always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			lft_sum_reg<=16'd0;
			lft_sum_reg<=16'd0;
		end
		
		else begin
			lft_sum_reg<=lft_sum;
			rght_sum_reg<=rght_sum;
		end
end



//multiplier
logic [28:0] lft_mult_result, rght_mult_result;
assign lft_mult_result=lft_sum_reg* {1'b0,POT_VOL};
assign rght_mult_result=rght_sum_reg* {1'b0,POT_VOL};

//out put
assign aud_out_lft=lft_mult_result[27:12];
assign aud_out_rght=rght_mult_result[27:12];

endmodule