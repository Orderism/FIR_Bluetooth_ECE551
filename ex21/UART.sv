module UART(clk,rst_n,RX,TX,rx_rdy,clr_rx_rdy,rx_data,trmt,tx_data,tx_done);

input clk,rst_n;
input RX,trmt;
input clr_rx_rdy;
input [7:0] tx_data;
output TX,rx_rdy,tx_done;

output [7:0] rx_data;

typedef enum reg {IDLE, RX_STATE} state_t;
state_t state, nxt_state;

reg [8:0] A001;
reg [3:0] A002;
reg [8:0] A003;
reg A004;
reg B001, B002;

reg A005,A006;
reg [8:0] A007;
reg [3:0] A008;
reg [8:0] A009;
reg tx_done;

reg A010, A011;

wire A012;
wire A013;

logic A014, A015, A016;


localparam IDLE_tx = 1'b0;
localparam TX_STATE = 1'b1;


always @(posedge clk or negedge rst_n)
  if (!rst_n)
    A005 <= IDLE_tx;
  else
    A005 <= A006;



always @(posedge clk or negedge rst_n)
  if (!rst_n)
    A008 <= 4'b0000;
  else if (A010)
    A008 <= 4'b0000;
  else if (A012)
    A008 <= A008+1;


always @(posedge clk or negedge rst_n)
  if (!rst_n)
    A009 <= 434;
  else if (A010 || A012)
    A009 <= 434;
  else if (A011)
    A009 <= A009-1;


always @(posedge clk or negedge rst_n)
  if (!rst_n)
    A007 <= 9'h1FF;
  else if (A010)
    A007 <= {tx_data,1'b0};
  else if (A012)
    A007 <= {1'b1,A007[8:1]};


always @(posedge clk or negedge rst_n)
  if (!rst_n)
    tx_done <= 1'b0;
  else if (trmt)
    tx_done <= 1'b0;
  else if (A008==4'b1010)
    tx_done <= 1'b1;


always @(*)
  begin
    A010         = 0;
    A011 = 0;
    A006    = IDLE_tx;
    
    case (A005)
      IDLE_tx : begin
        if (trmt)
          begin
            A006 = TX_STATE;
            A010 = 1;
          end
        else A006 = IDLE_tx;
      end
      default : begin
        if (A008==4'b1010)
          A006 = IDLE_tx;
        else
          A006 = TX_STATE;
        A011 = 1;
      end
    endcase
  end


assign A012 = ~|A009;
assign TX = A007[0];






always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;


always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    A002 <= 4'b0000;
  else if (A014)
    A002 <= 4'b0000;
  else if (A013)
    A002 <= A002+1;


always_ff @(posedge clk or negedge rst_n)
  
  if (!rst_n)
    A003 <= 217;
  else if (A014)
    A003 <= 217;
  else if (A013)
    A003 <= 434;
  else if (A016)
    A003 <= A003-1;


always_ff @(posedge clk)
  if (A013)
    A001 <= {B002,A001[8:1]};


always @(posedge clk or negedge rst_n)
  if (!rst_n)
    A004 <= 1'b0;
  else if (A014 || clr_rx_rdy)
    A004 <= 1'b0;
  else if (A015)
    A004 <= 1'b1;

	assign rx_rdy = A004;
	

always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    begin
      B001 <= 1'b1;
      B002 <= 1'b1;
    end
  else
    begin
      B001 <= RX;
      B002 <= B001;
    end

always_comb
  begin
    A014         = 0;
    A015    	  = 0;
    A016     = 0;
    nxt_state     = IDLE;
    
    case (state)
      IDLE : begin
        if (!B002)
          begin
            nxt_state = RX_STATE;
            A014 = 1;
          end
        else nxt_state = IDLE;
      end
      default : begin
        if (A002==4'b1010)
          begin
            A015 = 1;
            nxt_state = IDLE;
          end
        else
          nxt_state = RX_STATE;
        A016 = 1;
      end
    endcase
  end


assign A013 = ~|A003;
assign rx_data = A001[7:0];

endmodule
