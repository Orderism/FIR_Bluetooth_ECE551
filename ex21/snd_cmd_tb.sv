module snd_cmd_tb();

logic [4:0] cmd_start;
logic [3:0] cmd_len;
logic send , clk, rst_n, resp_rcvd, TX, RX;

snd_cmd isnd_cmd(.cmd_start(cmd_start), .send(send), .cmd_len(cmd_len), .clk(clk), .rst_n(rst_n), .resp_rcvd(resp_rcvd), .TX(TX), .RX(RX));

RN52_cmd_model iRN52(.clk(clk), .rst_n(rst_n), .initialized(initialized), .RX(TX), .TX(RX));

initial begin

clk = 0;
rst_n = 0;
send = 0;

//first command "S|,01\r"
@(posedge clk);
@(negedge clk) rst_n = 1;
@(posedge clk) begin
	cmd_start = 5'b00000;
	cmd_len = 4'b0110;
end

@(posedge clk) send = 1;
@(posedge clk) send = 0;

//second command "SN,ECE551\r"
@(posedge resp_rcvd) begin
	cmd_start = 5'b00110;
	cmd_len = 4'b1010;
end

@(posedge clk) send = 1;
@(posedge clk) send = 0;

//Was initialized asserted as expected?
@(posedge resp_rcvd)
if(initialized) begin
	$display("Success!");
	$stop();
end
else begin
	$display("Error!");
	$stop();
end

end

always
	#5 clk = ~clk;

endmodule