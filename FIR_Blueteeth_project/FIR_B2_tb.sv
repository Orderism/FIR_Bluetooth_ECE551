module FIR_B2_tb();
// level transmission signal
logic clk, rst_n;
logic TX;
logic I2S_sclk,I2S_ws,I2S_data;
logic  vld, sequencing;
logic [23:0]lft_chnnl, rght_chnnl;
logic [23:0]lft_chnnl_uf,rght_chnnl_uf;
logic [15:0]lft_out_hfq, rght_out_hfq;
logic [15:0]lft_out_B2, rght_out_B2; 
logic [15:0]lft_out_uf,rght_out_uf;



//RN-52
RN52 RN52_FIR(.cmd_n(1'b1), .RX(1'b1), .I2S_sclk(I2S_sclk), .I2S_ws(I2S_ws), .I2S_data(I2S_data),.clk(clk), .RST_n(rst_n), .TX(TX));


//I2S_Serf
//my code have put the vld ff inside the I2S_Serf
//howevver , the ff part need to be in the test bench work as a probe, which should not influence the real data
I2S_Serf I2S_Serf_FIR(.I2S_sclk(I2S_sclk), .I2S_ws(I2S_ws), .I2S_data(I2S_data), .vld(vld), .rght_chnnl(rght_chnnl), .lft_chnnl(lft_chnnl),.clk(clk), .rst_n(rst_n));


//high_freq_queue
high_freq_queue high_freq_queue_FIR(.lft_smpl(lft_chnnl[23:8]), .rght_smpl(rght_chnnl[23:8]), .wrt_smpl(vld), .lft_out(lft_out_hfq), .rght_out(rght_out_hfq), .sequencing(sequencing),.clk(clk), .rst_n(rst_n));


//FIR_B2
FIR_B2 FIR_B2_FIR(.lft_in(lft_out_hfq), .rght_in(rght_out_hfq), .sequencing(sequencing), .lft_out(lft_out_B2), .rght_out(rght_out_B2), .clk(clk), .rst_n(rst_n));

 always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rght_chnnl_uf<=24'd0;
		lft_chnnl_uf<=24'd0;


	end

	else if (vld) begin
		rght_chnnl_uf<=rght_chnnl;
		lft_chnnl_uf<=lft_chnnl;
	end
	else begin
		rght_chnnl_uf<=rght_chnnl_uf;
		lft_chnnl_uf<=lft_chnnl_uf;
	end
end

 always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		lft_out_uf<=16'd0;
		rght_out_uf<=16'd0;
	end

	else if (vld) begin
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
rst_n=0;

@(posedge clk);
rst_n=1;

@(posedge clk);
repeat (3000000) @(posedge clk);
$stop;


end

always #5 clk=~clk;
endmodule



