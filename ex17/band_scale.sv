module band_scale(POT, audio, scaled);
input [11:0]POT;
input [15:0]audio;
output [15:0]scaled;


wire [12:0]POT_13;
assign POT_13={POT[11],POT};//signed number 13bits

wire [28:0]m_result;
assign m_result=POT_13*audio;//multiple result 29 bits
wire [18:0]m_28to10;
assign m_28to10=m_result[28:10];//use for saturating
sat gjwl(.m_28to10(m_28to10), .scaled(scaled));



endmodule