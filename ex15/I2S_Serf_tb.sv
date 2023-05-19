module I2S_Serf_tb();
reg clk,rst_n;
logic [23:0]lft_chnnl_smpld, rght_chnnl_smpld;
//I2S_Monarch & I2S_Serf connection signal
wire I2S_sclk, I2S_ws, I2S_data;
//module I2S_Monarch(clk,rst_n,I2S_sclk,I2S_data,I2S_ws);
I2S_Monarch I2SM(.clk(clk), .rst_n(rst_n), .I2S_sclk(I2S_sclk), .I2S_data(I2S_data), .I2S_ws(I2S_ws));
//I2S_Serf
I2S_Serf I2SS(.clk(clk), .rst_n(rst_n), .I2S_sclk(I2S_sclk), .I2S_data(I2S_data), .I2S_ws(I2S_ws), .vld(vld), .lft_chnnl(lft_chnnl_smpld), .rght_chnnl(rght_chnnl_smpld));

initial begin
clk=0;
rst_n=0;


@(posedge clk) 
rst_n=1;

repeat(700000)@(posedge clk);
$stop();

end
always#5 clk=~clk;
endmodule