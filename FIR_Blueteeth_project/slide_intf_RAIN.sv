module slide_intf(POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME, SS_n, SCLK, MOSI, MISO, clk, rst_n);
//output
output logic [11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;
output wire SS_n, SCLK, MOSI;
//input
input wire MISO;
input wire clk, rst_n;
//connect signal
logic strt_cnv, cnv_cmplt;
wire [11:0]res;
logic [2:0]chnnl;
logic en_regs;

//module intf
A2D_intf A2D_slide(.strt_cnv(strt_cnv), .chnnl(chnnl), .cnv_cmplt(cnv_cmplt),
                   .res(res), .clk(clk), .rst_n(rst_n), .SCLK(SCLK), .MOSI(MOSI),
                   .MISO(MISO), .a2d_SS_n(SS_n));

//chnnl matching logic
//ENABLE SIGNAL BONDING WITH CHNNL

//A DFF SENDING res to ALL output POT  and waiting for enable
logic [11:0]res_reg;
always_ff @(posedge clk , negedge rst_n) begin
    if (!rst_n) 
        res_reg<=12'd0;
        else 
        res_reg<=res;
end

//allocate the res to different pot
//chnnl enbale
logic POT_B1_en, POT_LP_en, POT_B3_en, POT_HP_en,VOLUME_en,POT_B2_en;
assign POT_B1_en=((chnnl==3'b000) & en_regs);
assign POT_LP_en=((chnnl==3'b001) & en_regs);
assign POT_B3_en=((chnnl==3'b010) & en_regs);
assign POT_HP_en=((chnnl==3'b011) & en_regs);
assign POT_B2_en=((chnnl==3'b100) & en_regs);
assign VOLUME_en=((chnnl==3'b111) & en_regs);



always_ff@(posedge clk or  negedge rst_n) begin
    if (!rst_n) POT_B1<=12'd0;
    else if (POT_B1_en ) POT_B1<=res_reg;
     else  POT_B1<=POT_B1;
end

always_ff@(posedge clk or  negedge rst_n) begin
    if (!rst_n) POT_LP<=12'd0;
    else if (POT_LP_en ) POT_LP<=res_reg;
     else  POT_LP<=POT_LP;
end

always_ff@(posedge clk or  negedge rst_n) begin
    if (!rst_n) POT_B3<=12'd0;
    else if (POT_B3_en) POT_B3<=res_reg;
     else  POT_B3<=POT_B3;
end

always_ff@(posedge clk or  negedge rst_n) begin
    if (!rst_n) POT_HP<=12'd0;
    else if (POT_HP_en) POT_HP<=res_reg;
     else  POT_HP<=POT_HP;
end

always_ff@(posedge clk or  negedge rst_n) begin
    if (!rst_n) POT_B2<=12'd0;
    else if (POT_B2_en) POT_B2<=res_reg;
     else  POT_B2<=POT_B2;
end

always_ff@(posedge clk or  negedge rst_n) begin
    if (!rst_n) VOLUME<=12'd0;
    else if (VOLUME_en) VOLUME<=res_reg;
     else  VOLUME<=VOLUME;
end







//RRsequencer statemachine
typedef enum reg {IDLE, CMPLT} state;
state cur_state, nxt_state;

//FF
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) cur_state<=IDLE;
    else cur_state<=nxt_state;
end
//COMB
always@(*) begin
    //initial
    strt_cnv=0;
	 en_regs = 0;
    nxt_state=cur_state;
    
    
    case(cur_state)
    IDLE: 	begin 
        if (cnv_cmplt)begin
                en_regs = 1;
				nxt_state=CMPLT;
			end 
            else strt_cnv=1;
    end

    CMPLT:  begin
        if (!cnv_cmplt)  begin
            nxt_state=IDLE;
    end
    end
    endcase
end


logic [2:0]nxt_chnnl;
assign nxt_chnnl= (chnnl==3'b001)? 3'b000:
                    (chnnl==3'b000)? 3'b100:
                        (chnnl==3'b100)?3'b010:
                            (chnnl==3'b010)?3'b011:
                                (chnnl==3'b011)? 3'b111:
                                3'b001;

//could be replaced as comb_logic

always_ff@ (posedge clk or negedge rst_n) begin
    if(!rst_n)         chnnl<=3'b001;
    else if (en_regs) begin 
		chnnl<=nxt_chnnl;
    end
end


endmodule