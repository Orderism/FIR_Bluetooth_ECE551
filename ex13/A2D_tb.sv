module A2D_tb();

//A2D tb connect the A2D_intf and ADC128S

//A2D_tb control signal
//input strt_cnv, chnnl, clk, rst_n;
//output cnv_cmplt, [11:0] res, 
logic strt_cnv, clk, rst_n;
logic [2:0] chnnl;
logic cnv_cmplt;
logic [11:0] res;

//A2D_inf ADC128S connection signal
logic MISO, MOSI, a2d_SS_n, SCLK;


//A2D_intf() 
A2D_intf Aintf(.clk(clk), .rst_n(rst_n), .chnnl(chnnl), .cnv_cmplt(cnv_cmplt), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .res(res), .strt_cnv(strt_cnv));
//ADC128S
ADC128S ADC(.clk(clk),.rst_n(rst_n),.SS_n(a2d_SS_n),.SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));


initial begin
clk=0;
rst_n=0;
chnnl=3'b000;
strt_cnv=0;
//repeat (10) @(posedge clk);

//read 1 chnnl 1// junk data
@(posedge clk);
rst_n=1;
strt_cnv=1;
@(posedge clk);
strt_cnv=0;
chnnl=3'b001;
@(posedge cnv_cmplt);

//read 2 chnnl 1// Important data
@(posedge clk);
strt_cnv=1;
@(posedge clk);
strt_cnv=0;
chnnl=3'b001;
@(posedge cnv_cmplt);

//read 3 chnnl 4// junk data
@(posedge clk);
strt_cnv=1;
@(posedge clk);
strt_cnv=0;
chnnl=3'b100;
@(posedge cnv_cmplt);

//read 4 chnnl 4// important data
@(posedge clk);
strt_cnv=1;
@(posedge clk);
strt_cnv=0;
chnnl=3'b100;
@(posedge cnv_cmplt);


//read 5 chnnl 3// junk data
@(posedge clk);
strt_cnv=1;
@(posedge clk);
strt_cnv=0;
chnnl=3'b011;
@(posedge cnv_cmplt);

//read 6 chnnl 3// important data
@(posedge clk);
strt_cnv=1;
@(posedge clk);
strt_cnv=0;
chnnl=3'b011;
@(posedge cnv_cmplt);
$stop();





end

always #5 clk=~clk;

endmodule