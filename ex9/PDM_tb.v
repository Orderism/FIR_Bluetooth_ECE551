module PDM_tb();
//module PDM(clk, rst_n, duty, PDM, PDM_n);
reg clk, rst_n;
reg [15:0]duty;
wire PDM, PDM_n;

PDM P1(.clk(clk), .rst_n(rst_n), .duty(duty), .PDM(PDM), .PDM_n(PDM_n));


initial begin
clk=1'b0;
rst_n=1'b0;
duty = 16'd0;



#5
rst_n=1'b1;
//case1
duty=16'h8000;
repeat (16'd65535)@(posedge clk); 

//case2
duty=16'h0800;
repeat (16'd65535)@(posedge clk);

//case3
duty=16'h0080;
repeat (16'd65535)@(posedge clk);

//case4
duty=16'h0008;
repeat (16'd65535)@(posedge clk);

#50
$stop();








end




always #5 clk=~clk;

endmodule