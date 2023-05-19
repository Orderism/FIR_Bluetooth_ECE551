module sat(m_28to10, scaled);
input [18:0]m_28to10;
output [15:0]scaled;


//negative sat
wire [15:0]m1;
assign m1=((m_28to10[18]) && (m_28to10[18:16]!==3'b111))? 16'b1000_0000_0000_0000 : m_28to10[15:0];

//positive sat
wire [15:0]m2;
assign m2=((m_28to10[18]) && (m_28to10[18:16]!==3'b000))? 16'b0111_1111_1111_1111 : m_28to10[15:0];

//mux neg sat or pos sat
assign scaled= (m_28to10[18])? m1:m2;






endmodule