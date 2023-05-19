module slide_intf_tb();
//output slide_intf
logic [11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;
logic SS_n, SCLK, MOSI;
//input slide_intf
logic MISO;
reg clk, rst_n;
reg fail;
//input A2D
logic [11:0]LP, B1, B2, B3, HP, VOL;
int i;

//module slide_intf(POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME, SS_n, SCLK, MOSI, MISO, clk, rst_n);
slide_intf  sl_intf(.POT_LP(POT_LP), .POT_B1(POT_B1), .POT_B2(POT_B2), 
                  .POT_B3(POT_B3), .POT_HP(POT_HP), .VOLUME(VOLUME), 
                  .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), 
                  .MISO(MISO), .clk(clk), .rst_n(rst_n));
//module A2D_with_Pots(clk,rst_n,SS_n,SCLK,MISO,MOSI,LP,B1,B2,B3,HP,VOL);
A2D_with_Pots A2D_w_P(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), 
                     .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI),
		     .LP(LP), .B1(B1), .B2(B2), 
                     .B3(B3), .HP(HP), .VOL(VOL));

initial begin
clk=0;
rst_n=0;
i=0;
fail=0;
LP=0;
B1=0;
B2=0;
B3=0;
HP=0;
VOL=0;
@(posedge clk);
rst_n=1;

//Declare the value of LP, B1, B2, B3, HP, VOL;

fork


begin:value_input
for (i=0; i<1000; i=i+1) begin
	@(posedge clk);
	LP=LP+12'd1;
	B1=B1+12'd2;
	B2=B2+12'd3;
	B3=B3+12'd4;
	HP=HP+12'd5;
	VOL=VOL+12'd6;
	@(posedge clk);
end

repeat (10) @(posedge clk);
$stop();
end


begin:fail_check
@(posedge clk) begin
if (fail) $display("fialed");
else $display("all passed");
end


end
join
end

always #5 clk=~clk;


endmodule