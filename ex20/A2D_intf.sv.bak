//A2D intf 

//output 
//SCLK, MOSI_________ from the SPI_mnrch 
//res[11:0], cnv_cmplt________from A2D itself

//input 
//chnnl[2:0], strt_cnv, clk, rst_n

//signal between state machine and SPImnrch
//cmd[15:0],snd
//done, res[11:0]

module A2D_intf (clk, rst_n, chnnl, cnv_cmplt, a2d_SS_n, SCLK, MOSI, MISO, res, strt_cnv);
//input from the tb
input logic [2:0]chnnl;
input logic strt_cnv, clk, rst_n;
output logic cnv_cmplt;
output logic [11:0]res;

//data flow between A2D_intf and SPI_mnrch
output logic a2d_SS_n, SCLK, MOSI;
input logic MISO;

//control signal between state machine and SPI_mnrch
logic snd, done;
logic [15:0] cmd;
logic [15:0]resp;
assign cmd = {2'b00,chnnl,11'h000};
assign res = resp[11:0];


//connect with SPI mnrch
SPI_mnrch smn(.cmd(cmd), .resp(resp), .snd(snd), .done(done), .SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .rst_n(rst_n), .clk(clk));

//signal of the state machine
reg cnv_cmp;
reg dl1_done;//for delay 1 cycle from the done


typedef enum reg [1:0] {IDLE, CMD, DONE} state;
//CMD: send the 0x0800 to SPI machine as cmd
state cur_state, nxt_state;
//state transmission
//at least one cycle empty before next initial
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        cur_state <= IDLE;
    else 
        cur_state <= nxt_state;
end

always_comb begin
    snd=1'b0;
    cnv_cmp=1'b0;// cmplt signal in state machine
    nxt_state = cur_state;//keep hold state

case(cur_state)
    IDLE: begin
        if(strt_cnv) begin
            nxt_state = CMD;
            snd=1'b1;
        end
        else 
            nxt_state = IDLE;   
    end

    CMD: begin// send the command and wait for 16 SCLK use cnv trigger the cmd and rcv trigger the recieve
        if (done) begin// from the strt_cnv with a cnt
            snd=1'b0;
            nxt_state = DONE;
        end
        else
            nxt_state = CMD;
    end

    DONE: begin// WAIT FOR 1 CYCLE
        if(dl1_done) begin
            nxt_state = IDLE;
            cnv_cmp=1'b1;
        end
        else
            nxt_state = DONE;
    end

    default: begin
        nxt_state = IDLE;    
    end
endcase
end

//16 bit cnter 
//when we start the cmd sending or feed back recieving, cnt 16 bit to trigger nxt state;
/* NOT SURE IT WILL BE USED OR NOT
reg [3:0]b16_cnt;
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cmp<=0;
        b16_cnt<=4'd0;
    end
    else if (b16_cnt=4'd15) begin
        cnv_cmp<=1;
        b16_cnt<=4'd1;
    end
    else if (cnv_strt) begin
        b16_cnt<=b16_cnt+4'd1;
        cmp<=0;
    end 
    else begin
        b16_cnt<=b16_cnt;
        cmp<=0;
    end
end
*/


//cnv_cmplt ff output
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        cnv_cmplt<=0;
    else if (strt_cnv)
        cnv_cmplt<=0;
    else if (dl1_done)
        cnv_cmplt<=1;
    else 
        cnv_cmplt<=cnv_cmp;
end



//delay 1 cycle from the send command state to recieve feedback state;

always_ff@(posedge clk or negedge rst_n) begin
if (!rst_n) 
    dl1_done<=1'b0;
else if(done)
    dl1_done<=1'b1;
else if (strt_cnv)
    dl1_done<=1'b0;
else
    dl1_done<=1'b0;
end
endmodule