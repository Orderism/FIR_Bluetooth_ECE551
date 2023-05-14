module counter(clk,rst_n,en,up_dwn_n,cnt);
/////////////////////////////////////////////
// 8-bit up/down counter with enable with //
// active low reset.  When rst_n is low  // 
// the counter resets to 0x00. When en //
// is high counter counts up or down   //
// depending on state of: up_dwn_n.   //
// When en is low count freezes.     //
//////////////////////////////////////

input wire clk, rst_n;		// positive edge triggered, reset active low
input wire en, up_dwn_n;		// control signals

output logic [7:0]cnt;	       // output of type logic (system verilog type)

always_ff @(posedge clk, negedge rst_n) 
  if (!rst_n)
    cnt <= 8'h00;			// active low reset to 0x00
  else if (en)				// allowed to count
    if (up_dwn_n)
	  cnt <= cnt + 1;		// count up
	else
	  cnt <= cnt - 1;		// count down

endmodule
