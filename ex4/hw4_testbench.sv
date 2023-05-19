module hw4_testbench();
logic clk;
logic d;
wire q;

hw4 iDUT(.clk(clk), .d(d), .q(q));

initial begin
    clk=0;
    d=0;
    #5

    @(posedge clk)
    d=1;
    repeat (5)@(posedge clk);
    d=0;
    repeat (10)@(posedge clk);
    d=1;
    repeat (15)@(posedge clk);
    d=0;
    $stop();
end

always #5 clk=~clk;
endmodule