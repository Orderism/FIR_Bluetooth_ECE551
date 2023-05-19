module SPI_mnrch (cmd, clk, rst_n, snd, SS_n, SCLK, MOSI, MISO, done, resp);
input clk, rst_n;
input reg MISO;// input data: data LSB always be sent to the MISO and stored one by one
input snd;
input [15:0]cmd;//input data

reg SS_n_reg;
 
output SS_n, SCLK, MOSI;//output data : data MSB always stored in MOSI and be sent one by one
output done;
output [15:0]resp;//DATA from SPI serf?
reg init, shft, setdone, ld_SCLK, samp;//state machine output to the other blocks

//cnt control and flag signals
reg [3:0]b16_cnt;
//reg [1:0]delay2_cnt;
reg b16_done;
reg full;//for SS_n re-high control
reg MISO_samp;//temp for MISO sample

//SCLK cnt
reg [4:0] SCLK_div;// counter for the SCLK 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SCLK_div<=5'b10111;
    end

    else if (ld_SCLK) begin
        SCLK_div<=5'b10111;
    end

    else begin // when SS_n is low, start the SCLK logic
        if (SCLK_div==5'b11111) begin
            SCLK_div<=5'd0;
        end

        else begin
            SCLK_div<=SCLK_div+1'b1;
        end
    end
end
assign SCLK= SCLK_div[4];

//SCLK edge test
wire posedge_sclk, negedge_sclk;
reg pre1_SCLK, pre2_SCLK;
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
    pre1_SCLK<=1'b0;
    pre2_SCLK<=1'b0;
    end

    else begin
    pre1_SCLK<=SCLK;
    pre2_SCLK<=pre1_SCLK;
    end
end

assign posedge_sclk=~pre2_SCLK && pre1_SCLK;// flag signal will exist 1 system clk period
assign negedge_sclk=pre2_SCLK && ~pre1_SCLK;

//state machine
//we got 4 state for the SPI
//
//IDLE: The SS_n has be 0 and we are waiting for the 1st posedge SCLK
//WAIT: The posedge SCLK has got and wait for 2 more clk to remove the glitch
//SHIFT: The work as a shifter
//DONE: output the done flag and back to IDLE
//MISO input and MOSI output could be connect with combinational logic outside the always block
// the state machine signal as follow :
//int, ld_SCLK, shft, setdone
typedef enum reg[1:0] {IDLE, WAIT, SHIFT, DONE} state;
state nxt_state, cur_state;
// state trans
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
//state machine logic
//there is a lot of other models working by the control signal from the state machine
//the state machine should far away from the actual working like shifter or other something else
//the output from state machine could be only the control signal!!!!!
always_comb begin
    //default
    nxt_state=IDLE;
    init=1'b0;//init always = ~SS_n
    shft=1'b0;
    samp=1'b0;
    setdone=1'b0;            
    ld_SCLK=1'b0;

    case (cur_state)// all the re-evaluate is happened when go to next stage
    IDLE: begin//IDLE: The SS_n has be 0 and we are waiting for the 1st posedge SCLK
        if (snd) begin    
            ld_SCLK=1'b0;
            init=1'b1;
            nxt_state=WAIT;
        end
        else begin
            ld_SCLK=1'b0;
            nxt_state=IDLE;
        end
    end

    WAIT: begin//WAIT: The posedge SCLK has got and wait for 2 more clk to remove the glitch
        if (posedge_sclk) begin
            init=1'b0;
            nxt_state=SHIFT;
        end
        else begin
            init=1'b1;
            nxt_state=WAIT;
        end
    end

    SHIFT: begin
           case({posedge_sclk, negedge_sclk, b16_done})
               3'b001: begin//the 1st posedge when 16bit cnt done, jump to nxt_state
                    shft=1'b0;                    
                    samp=1'b0;                    
                    nxt_state=DONE;end
               3'b100: begin//posedge for shift MOSI                
                    shft=1'b1;
                    nxt_state=SHIFT;end
               3'b010: begin//negedge for samle MOSI                    
                    samp=1'b1;
                    nxt_state=SHIFT;end
               default: begin                  
                    nxt_state=SHIFT;end
           endcase
        /*if (posedge_sclk) begin
            if (b16_done) begin
                init=1'b0;
                shft=1'b0;
                ld_SCLK=1'b1;
                nxt_state=DONE;
            end
            else begin
                nxt_state=SHIFT;
            end
        end
        else begin
            init=1'b0;
            shft=1'b1;
            nxt_state=cur_state;
        end*/
             end

    DONE: begin
           setdone=1'b1;
           ld_SCLK=1'b1;
       if (posedge_sclk) begin
           nxt_state=cur_state;
       end
       else if(SS_n_reg) begin
           nxt_state=IDLE;
       end
       else begin
           nxt_state=cur_state;       
       end
       end
    
endcase
end

//Sample logic
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        MISO_samp<=1'b0;
    end
    else if (samp) begin//////////
        MISO_samp<=MISO;
    end
    else begin
        MISO_samp<=MISO_samp;
    end  
end

//Main shift register with mux
reg [15:0]shft_reg;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shft_reg<=16'd0;
    end
    else begin
    case({init, shft})
        2'b11,2'b10:shft_reg<=cmd;
        2'b01:shft_reg<={shft_reg[14:0], MISO_samp};
        2'b00:shft_reg<=shft_reg;
    endcase
    end
end
assign MOSI= (SS_n) ? 1'bz : shft_reg[15];


//16bit shifter cnt
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        b16_cnt<=4'd0;
        b16_done<=4'd0;
    end
    else if (shft) begin
        if(posedge_sclk) begin
            if (b16_cnt==4'b1111) begin 
                b16_cnt<=4'd0;
                b16_done<=1'b1;
            end
            else begin
                b16_cnt<=b16_cnt + 4'd1;
                b16_done<=1'b0;
            end
        end 
        else b16_cnt<=b16_cnt;
    end
    else begin
        b16_cnt<=b16_cnt;
        b16_done<=1'b0;
    end
end

//full logic, for half sclk delay on SS_n output, start from set_done to set_done + 16clk
//setdown-enable cnt
reg [4:0]full_cnt;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        full_cnt<=2'd0;
        full<=1'b0;
    end

    else if (setdone) begin
        if(full_cnt==4'b1111)begin
            full_cnt<=4'd0;
            full<=1'b1;
        end
        else begin
            full_cnt<=full_cnt + 4'd1;///
            full<=1'b0;
        end
    end

    else begin
        full_cnt<=4'd0;
        full<=1'b0;
    end
end


//SS_n logic

always_ff@(posedge clk or negedge rst_n) begin
if(!rst_n) begin
SS_n_reg<=1'b1;
end
else if (init && (SS_n_reg)) begin//start logic
SS_n_reg<=1'b0;
end
else if ((full) && (~init) && (~SS_n_reg)) begin//end logic
SS_n_reg<=1'b1;
end
else begin//hold logic
SS_n_reg<=SS_n_reg;
end
end
assign SS_n=SS_n_reg;

//done logic
reg done_reg;
always_ff@(posedge clk or negedge rst_n) begin
if(!rst_n) begin
done_reg<=1'b0;
end
else if(full) begin//
done_reg<=1'b1;
end
else done_reg<=1'b0;
end
assign done=done_reg;



//resp logic
assign resp=shft_reg;

endmodule

