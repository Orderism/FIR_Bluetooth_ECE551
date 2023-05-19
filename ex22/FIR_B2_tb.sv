module FIR_B2_tb();
// level transmission signal
wire TX;
wire I2S_sclk,I2S_ws,I2S_data;
wire lft_chnnl, rght_chnnl, vld;
wire lft_chnnl_uf,rght_chnnl_uf;
wire lft_smpl,rght_smpl;
wire lft_out_hfq, rght_out_hfq, sequencing;
wire lft_out_B2, rght_out_B2; 
wire lft_out_uf,rght_out_uf;



//RN-52
RN52 RN52_FIR(.cmd_n(1'b1), .RX(1'b1), .I2S_sclk(I2S_sclk), .I2S_ws(I2S_ws), .I2S_data(I2S_data));


//I2S_Serf
//my code have put the vld ff inside the I2S_Serf
//howevver , the ff part need to be in the test bench work as a probe, which should not influence the real data
I2S_Serf I2S_Serf_FIR(.I2S_sclk(I2S_sclk), .I2S_ws(I2S_ws), .I2S_data(I2S_data), .vld(vld), .rght_chnnl(rght_chnnl), .lft_chnnl(lft_chnnl));

always_ff @(posedge clk) begin
	if (vld) begin
		rght_chnnl_uf<=rght_chnnl;
		lft_chnnl_uf<=lft_chnnl;
	end
	else begin
		rght_chnnl_uf<=rght_chnnl_uf;
		lft_chnnl_uf<=lft_chnnl_uf;
	end
end

//high_freq_queue
high_freq_queue high_freq_queue_FIR(.lft_smpl(lft_chnnl), .rght_smpl(rght_chnnl), .wrt_smpl(vld), .lft_out(lft_out_hfq), .rght_out(rght_out_hfq));


//FIR_B2
FIR_B2 FIR_B2_FIR(.lft_in(lft_out_hfq), .rght_in(rght_out_hfq), .sequencing(sequencing), .lft_out(lft_out_B2), .rght_out(rght_out_B2));

always_ff @(posedge clk) begin
	if (vld) begin
		lft_out_uf<=lft_out_B2;
		rght_out_uf<=rght_out_B2;
	end
	else begin
		lft_out_uf<=lft_out_uf;
		rght_out_uf<=rght_out_uf;
	end
end

initial begin
clk=0;

lftin=0
rghtin=0






end

always #5 clk=~clk;
always #5 rght_in=~rght_in;
always #123213 lft_in=lft_in;
endmodule




