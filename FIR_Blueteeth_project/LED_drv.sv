module LED_drv(clk, rst_n, vld, aud_out_lft, aud_out_rght, LED);
input logic clk, vld, rst_n;
input logic[15:0] aud_out_lft, aud_out_rght;
output logic [7:0] LED;

//split 4 level of the LED part, when the output is big value, open all led lights in it's side
logic unsigned [14:0] aud_out_lft_abs, aud_out_rght_abs;

assign aud_out_lft_abs=(aud_out_lft[15])? (~(aud_out_lft[14:0])+15'b1):
                                            aud_out_lft[14:0];                                            
assign aud_out_rght_abs=(aud_out_rght[15])? (~(aud_out_rght[14:0])+15'b1):
                                            aud_out_rght[14:0];






always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        LED<=8'd0;
    end
    else if(vld) begin
        LED[0]<=(|aud_out_rght_abs[3:0]);
        LED[1]<=(|aud_out_rght_abs[7:4]);
        LED[2]<=(|aud_out_rght_abs[11:8]);
        LED[3]<=(|aud_out_rght_abs[14:11]);
        LED[4]<=(|aud_out_lft_abs[3:0]);
        LED[5]<=(|aud_out_lft_abs[7:4]);
        LED[6]<=(|aud_out_lft_abs[11:8]);
        LED[7]<=(|aud_out_lft_abs[14:11]);
    end

end


endmodule

