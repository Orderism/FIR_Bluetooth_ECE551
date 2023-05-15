module dff(D,clk,PRN,Q);

  /////////////////////////////////////////
  // D-FF with active low asynch preset //
  ///////////////////////////////////////

  input D;
  input clk;
  input PRN;		// active low preset (sets to 1)
  output reg Q;

  always @(posedge clk, negedge PRN)
    if (!PRN)
	  Q<= 1'b1;
	else
      Q <= D;
  
endmodule