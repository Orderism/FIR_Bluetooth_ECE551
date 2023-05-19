module DriveA2D (btn_release, clk, rst_n, chnnl, strt_cnv);
input logic btn_release, clk, rst_n;
output logic [2:0] chnnl;
output logic strt_cnv;

//btn release rise edge test

reg btn_release_temp;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        btn_release_temp<=0;    
    end
    else begin
        btn_release_temp<=btn_release;
    end
end

wire btn_posedge;
assign btn_posedge=(~btn_release_temp) && btn_release; 

//STRT CNV assertion
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        strt_cnv<=0;    
    end
    else if(btn_posedge) begin
        strt_cnv<=1;
    end
    else begin
        strt_cnv<=0;
    end
end


//increament of the chnnl
reg chnnl_reg;
always_ff@(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        chnnl_reg<=3'd0;
    end
    else if(btn_posedge) begin
        chnnl_reg<=chnnl+3'd1;
    end
    else if(chnnl_reg==3'd7) begin
        chnnl_reg<=chnnl+3'd0;
    end
    else begin
        chnnl_reg<=chnnl_reg;
    end
end
assign chnnl= chnnl_reg;

endmodule