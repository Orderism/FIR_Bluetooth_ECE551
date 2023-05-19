module bt_intf (nxt_n, prev_n, RX, cmd_n, TX, clk, rst_n);
input wire nxt_n;
input wire prev_n;
input wire RX;
output reg cmd_n;
output wire TX;


//clk & reset come from outside or insie module rst_sunch?

input logic clk, rst_n; 

//PB release module for nxt button
////module PB_release(PB, clk, rst_n, RST_n, released);
logic PB_release1,PB_release2;
PB_release PBL_NXTB(.PB(nxt_n), .clk(clk), .rst_n(rst_n), .released(PB_release1));
//PB release module for prev button
PB_release PBL_PREVB(.PB(prev_n), .clk(clk), .rst_n(rst_n), .released(PB_release2));

//connect signal for the snd_cmd module
logic [4:0]cmd_start;
logic send;
logic [3:0]cmd_len;

//snd_cmd module 
//module snd_cmd(cmd_start, send, cmd_len, clk, rst_n, resp_rcvd, TX, RX);
snd_cmd sc_bt(.send(send), .cmd_start(cmd_start), .cmd_len(cmd_len), .resp_rcvd(resp_rcvd), .TX(TX), .RX(RX), .clk(clk), .rst_n(rst_n));



//cntrl SM & support logic
logic [1:0]cnt_init3;
logic init3_done;

//17 bits timer
logic [4:0]cnt17;
logic cnt17_done;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt17<=5'd0;
		cnt17_done<=0;
	end
		
	else begin
		if(cnt17==5'd17) begin
			cnt17<=5'd0;
			cnt17_done<=1;
		end
		else begin
			cnt17<=cnt17+5'd1;
			cnt17_done<=cnt17_done;
		end	
	end
end


//SM for the control of the cmd_n signal
/*
After reset cmd_n is held high until a 17-bit timer
expires. Then cmd_n is lowered. The lowering of
cmd_n will produce a response from the RN-52.
*/


typedef enum reg [1:0] {IDLE, INIT_1, INIT_2, WAIT_PB} state;
state cur_state, nxt_state;


always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) cur_state<=IDLE;
	else cur_state<=nxt_state;
end

always_comb  begin
    	nxt_state = cur_state;
	cmd_n = 1;
	send=0;
	cmd_start=5'd0;//1st instruction
	cmd_len=4'd6;


	case(cur_state)
	IDLE: begin
		if (cnt17_done) begin
		cmd_n=0;	
		send=1;
			if (resp_rcvd) begin	
				nxt_state=INIT_1;
			end
		end
	end
	
	INIT_1:begin 
		cmd_n=0;
		if (resp_rcvd) begin // 1st instruction sent
		send=1;
		nxt_state=INIT_2;
		cmd_start=5'd6;
		cmd_len=4'd10;
		end
	end

	INIT_2:begin 
		cmd_n=0;
		if (resp_rcvd)  begin// 1st instruction sent
		nxt_state=WAIT_PB;
		end
	end

	
	WAIT_PB: begin//stay here forever
		cmd_n=0;	
		nxt_state=WAIT_PB;
		if (PB_release1) begin
		send=1;
		cmd_start=5'd16;
		cmd_len=4'd4;
		end
		else if (PB_release1) begin
		send=1;
		cmd_start=5'd20;
		cmd_len=4'd4;
		end
	end


	endcase
end

//init 3 flag // 1st for the lower cmd_n, 2nd for the 1st initial instruction, 3rd for the last initial instruction
//posdge detector
/*
reg resp_rcvd_temp;
always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n)  resp_rcvd_temp<=1'd0;
else resp_rcvd_temp<=resp_rcvd;
end
assign pos_resp= (~resp_rcvd_temp) & resp_rcvd_temp;

//cnter for 3 time detection

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		cnt_init3<=2'd0;
		init3_done<=0;
		end
		
	else if (resp_rcvd)//enabale increasing signal
		begin
			if(cnt_init3==2'd2) begin
				cnt_init3<=2'd0;
				init3_done<=1;
				end
			else begin
				cnt_init3<=cnt_init3+2'd1;
				init3_done<=0;
				end	
		end
end


*/




//cmd in different stage
//send signal
// a flag to show RX drop(&RX)
/*
always_ff @(posedge clk or negedge rst_n) begin// will only work in the init state
	if (!rst_n) 
		cmd_start<=5'd0;
	else if (cur_state==INIT) begin
		if (cnt_init3==2'b1) begin//1st end, it could be replaced because start from 0
			cmd_start<= 5'd0;
			cmd_len<=4'd6;
			end
		else if (cnt_init3==2'd2)  begin//2nd send:
			cmd_start<=5'd6;
			cmd_len<=4'd10;
		end
	end
	else if (cur_state==WAIT_PB) begin// work in the WAIT_PB state
		if (PB_release1) begin// send the AT+R, NXT
			cmd_start<=5'd16;
			cmd_len<=4'd4;
		end	
		else if (PB_release2) begin// send the AT+R, PREV
			cmd_start<=5'd20;		
			cmd_len<=4'd4;
		end
	end		
		else 
		cmd_start<=cmd_start;
end					
*/



endmodule