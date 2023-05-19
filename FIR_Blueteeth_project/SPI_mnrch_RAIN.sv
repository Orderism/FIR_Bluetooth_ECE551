/**
main datapath blocks
one to generate sclk
one is the main shift register

- a bit counter, n sclk divider counter, the main shift register, then a state machine to control it
*/

module SPI_mnrch(snd, /*cmd*/chnnl, done, resp, SS_n, SCLK, MOSI, MISO, clk, rst_n);

//input [15:0] cmd;
input [2:0] chnnl;
input snd, MISO, clk, rst_n;
output [15:0] resp;
output done, SS_n, SCLK, MOSI;

logic full, shift, init, ld_SCLK, done, done16, set_done, SS_n;
logic [4:0] d1, q1, d3, q3;
logic [15:0] d2, shift_reg;

//use chnnl replace the input
logic [15:0]cmd;
assign cmd = {2'd0,chnnl,11'd0};



//assigning reponse
assign resp = shift_reg;

//SCLK divider counter
assign d1 = ld_SCLK ? (5'b10111) : (q1 + 5'd1) ;

always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) q1<=0;
	else q1 <= d1;
end

assign SCLK = q1[4];

assign full = &q1;// ? 1'b1 : 1'b0;
assign shift = (5'b10001 == q1);// ? 1'b1 : 1'b0;

//main shift register

assign d2 = init ? cmd[15:0] : (shift ? {shift_reg[14:0], MISO} : shift_reg[15:0]);

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) shift_reg<=0;
	else shift_reg <= d2;
end
assign MOSI = shift_reg[15];

//bit counter

assign d3 = init ? 5'b00000 : (shift ? (q3 + 5'd1) : q3);

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) q3<=0;
	else q3 <= d3;
end
assign done16 = (q3[4] & (~|q3[3:0]));//(5'b10000 == q3);// ? 1'b1 : 1'b0;

//state machine

typedef enum logic[1:0]{IDLE, SHIFT, BACK_PORCH}state_t;
state_t state, next_state;

//flip flop for the state machine
always_ff @(posedge clk, negedge rst_n) begin
if(!rst_n)
state <= IDLE;
else
state <= next_state;
end
//setting all outputs before
always_comb begin
next_state = state;
ld_SCLK = 1;
init = 0;
set_done = 0;

case(state)
	//SHIFT state
	SHIFT: begin
		ld_SCLK = 0;
	if(done16) next_state = BACK_PORCH;	
	end


	//BACK_PORCH state
	BACK_PORCH:if(full) begin
	next_state = IDLE;
	set_done = 1;
	end
	else
	ld_SCLK = 0;

	//IDLE state
	default: if(snd) begin
	next_state = SHIFT;
	init = 1;
	ld_SCLK = 0;
	end
	endcase
end

//logic for SS_n so it doesn't glitch
always_ff @(posedge clk, negedge rst_n)
if(!rst_n)
SS_n <= 1;
else if(init)
SS_n <= 0;
else if(set_done)
SS_n <= 1;

//logic for done so it doesn't glitch
always_ff @(posedge clk, negedge rst_n)
if(!rst_n)
done <= 0;
else if(init)
done <= 0;
else if(set_done)
done <= 1;

endmodule


/**
My personal notes:
in idle until send recieved

first thing it would do is initialize hardware
ld_sclk asserted whole time while in idle

then in main shifting state
when done 16 times almost done
2 system clocks after last shift -> back porch (transaction ends when the last clock would have fuallen
* wait for full signal theen assert done (after spi transacction is over we assert done) data is ready and in shift register
initialize knows done down, when "done" (in back porch state waiting for full) we are actlly done and set done
3 state machine ,idle, main shifting state, after done16 into backporch state waiting for full, then hit set_done and go back to idle
*/
