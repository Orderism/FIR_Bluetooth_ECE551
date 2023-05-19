module band_scale(POT, audio, scaled);
input [11:0]POT;
input signed [15:0]audio;
output signed [15:0]scaled;

wire [23:0]POT_sqr;
assign POT_sqr=POT*POT;

wire signed [12:0]POT_13;
assign POT_13={1'b0,POT_sqr[23:12]};//signed number 13bits

wire signed [28:0]m_result;
assign m_result=POT_13*audio;//multiple result 29 bits

wire [18:0]m_28to10;
assign m_28to10=m_result[28:10];//use for saturating

sat gjwl(.m_28to10(m_28to10), .scaled(scaled));



endmodule