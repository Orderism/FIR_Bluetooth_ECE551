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
logic [15:0]resp;
assign res = resp[11:0];
//assign cmd = {2'd0,chnnl,11'd0};

//connect with SPI mnrch
SPI_mnrch smn(.chnnl((chnnl)), .resp(resp), .snd(snd), .done(done), .SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .rst_n(rst_n), .clk(clk));


typedef enum reg [1:0] {IDLE, CMD, DL1, DONE} state;
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
    cnv_cmplt=1'b0;// cmplt signal in state machine
    nxt_state = cur_state;//keep hold state


case(cur_state)


    CMD: begin// send the command and wait for 16 SCLK use cnv trigger the cmd and rcv trigger the recieve
        if (done) begin// from the strt_cnv with a cnt
            nxt_state = DL1;
        end
    end

    DL1: begin
        snd=1;
        nxt_state=DONE;
    end

    DONE: begin// WAIT FOR 1 CYCLE
        if(done) begin
            nxt_state = IDLE;
            cnv_cmplt=1'b1;
        end
    end

    /*IDLE*/default: begin
        if(strt_cnv) begin            
            snd=1'b1;
            nxt_state = CMD;
        end
    end

endcase
end




endmodule