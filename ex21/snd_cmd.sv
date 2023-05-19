module snd_cmd(cmd_start, send, cmd_len, clk, rst_n, resp_rcvd, TX, RX);

input [4:0] cmd_start;
input send, clk, rst_n, RX;
input [3:0] cmd_len;
output resp_rcvd, TX;

logic last_byte, inc_addr, trmt, tx_done, rx_rdy;
logic [4:0] addr, final_pos;
logic [7:0] dout, rx_data;

//Instantiating other parts

cmdROM icmdROM(.clk(clk), .addr(addr), .dout(dout));

UART iUART(.clk(clk), .rst_n(rst_n), .RX(RX), .TX(TX), .rx_rdy(rx_rdy),
.clr_rx_rdy(rx_rdy), .rx_data(rx_data), .trmt(trmt), .tx_data(dout), .tx_done(tx_done));

//flip flop going into cmdROM

always_ff @(posedge clk)
	addr <= send ? cmd_start : (inc_addr ? addr + 1 : addr); // should I include the [4:0]?

//flip flop that holds length + start position

always_ff @(posedge clk)
	final_pos <= send ? cmd_len + cmd_start : final_pos; //could use if statements?

assign last_byte = (addr == final_pos);

//state machine!

typedef enum logic[1:0]{IDLE, WAIT, TRANSMIT, WAIT_DONE}state_t;
state_t state, next_state;

always_ff @(posedge clk, negedge rst_n)
if(!rst_n)
	state <= IDLE;
else
	state <= next_state;

always_comb begin
	next_state = state;
	inc_addr = 0;
	trmt = 0;

case(state)
	WAIT_DONE: if(tx_done && last_byte)
			next_state = IDLE;
		else if(tx_done)
			next_state = TRANSMIT;

	TRANSMIT: begin
		trmt = 1;
		inc_addr = 1;
		next_state = WAIT_DONE;		
	end

	WAIT: begin
		next_state = TRANSMIT;
	end

	//IDLE
	default: if(send)
		next_state = WAIT;

endcase

end

//for asserting resp_rcvd once we get 0x0A
assign resp_rcvd = rx_rdy && (rx_data == 8'h0A);

endmodule