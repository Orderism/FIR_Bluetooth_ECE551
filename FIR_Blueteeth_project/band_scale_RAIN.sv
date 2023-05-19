module band_scale(POT, audio, scaled, clk, rst_n);
input [11:0]POT;
input signed [15:0]audio;
output reg signed [15:0]scaled;
input clk, rst_n;

wire [23:0]POT_sqr;


//POT*POT= [ {6'd0,POT[5:0]} + {POT,6'd0} ] *  [ {6'd0,POT[5:0]} + {POT,6'd0} ] 

wire[5:0] A,B;
assign A=POT[5:0];
assign B=POT[11:6];

wire[11:0] A_sqr, B_sqr;
wire[11:0] AB;
assign A_sqr=A*A;
assign B_sqr=B*B;
assign AB= A*B;

wire [23:0]AB_2, Asq_Bsq;
assign Asq_Bsq={12'd0, A_sqr}+{B_sqr,12'd0};
assign AB_2={5'd0,AB,7'd0};
assign POT_sqr=Asq_Bsq+AB_2;//POT*POT


//insert a ff for dl1, because the when input data get POT^2, it almost over the setup time
logic signed [12:0]POT_13;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin POT_13<=13'd0; end
    else begin POT_13<={1'b0,POT_sqr[23:12]}; end//signed number 13bits
end




reg signed [28:0]  m_result; 
wire signed [28:0] K;
assign K=POT_13*audio;//multiple result 29 bits


//same to previous, multiple waste lot of time
always	@(posedge clk, negedge rst_n) begin
    if (!rst_n) m_result<=29'd0;
    else m_result<=K;//signed number 13bits
end









wire sat_flag_neg;
wire sat_flag_pos;

assign sat_flag_neg = m_result[28] & ~(&m_result[27:25]);
assign sat_flag_pos = ~m_result[28] & (|m_result[27:25]);


wire [15:0]scaled_pre;
assign scaled_pre = sat_flag_neg ? 16'h8000 : (sat_flag_pos ? 16'h7FFF : m_result[25:10]);


always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) scaled<=16'd0;
    else scaled<= scaled_pre;

end
endmodule