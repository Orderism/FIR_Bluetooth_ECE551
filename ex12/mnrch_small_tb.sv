module mnrch_small_tb;
reg clk, rst_n, SS_n, SCLK, MOSI, done;
reg MISO;
reg [15:0] cmd, resp;
reg snd;


//initantiate DUT
//module SPI_mnrch (cmd, clk, rst_n, snd, SS_n, SCLK, MOSI, MISO, done, resp);
//output MOSI SCLK SS_n done resp
//input  clk, rst_n, MISO, snd, cmd 
SPI_mnrch mn(.cmd(cmd),.clk(clk), .rst_n(rst_n), .snd(snd), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI),
             .MISO(MISO), .done(done), .resp(resp));

//input  clk, rst_n, MISO, , cmd 
initial begin
clk=0;
rst_n=0;
snd=0;
MISO=1;
//cmd = read channel 1
cmd={2'b00, 3'b001, 11'h000};
//deassert reset after the 1st clk
@(posedge clk);
@(negedge clk);
rst_n=1;
//give it a pulse on snd (wrt), why????????
@(negedge clk);
snd=1;
@(negedge clk)
snd=0;
@(posedge done);// wait for the response of the initial set


repeat (8'd60)@(posedge clk);
$stop();
end


always #5 clk<=~clk;
endmodule
