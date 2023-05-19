module PDM_test_tb();
logic clk, RST_n, PB;
logic [7:0]LED;
logic [3:0]LEDcnt;

//module PDM_test(clk,RST_n,PB,LED);



PDM_test PD(.clk(clk), .RST_n(RST_n), .PB(PB), .LED(LED), .LEDcnt(LEDcnt));
initial begin
RST_n=1'b0;
clk=1'b0;
PB=1'b0;

#10
RST_n=1'b1;

repeat (16'd65535)@(posedge clk);
#50
$finish();
end

always #5 clk=~clk;
always #7 PB=~PB;

endmodule