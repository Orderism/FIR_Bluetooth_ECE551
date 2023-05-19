module spkr_drv(clk,rst_n,vld,lft_chnnl,rght_chnnl,lft_PDM,
                rght_PDM,lft_PDM_n,rght_PDM_n);
				
  input clk, rst_n;
  input vld;			// indicates new chnnl sample is valid
  input signed [15:0] lft_chnnl;
  input signed [15:0] rght_chnnl;
  output lft_PDM;
  output rght_PDM;
  output lft_PDM_n;
  output rght_PDM_n;
  
  
  /////////////////////////////////////////////////////
  // registers to capture chnnl data from EQ engine //
  ///////////////////////////////////////////////////
  reg signed [15:0] lft_reg, rght_reg;
  
  ////////////////////////////
  // Infer channel capture //
  //////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
	  lft_reg <= 16'h0000;
	  rght_reg <= 16'h0000;
	end else if (vld) begin
	  lft_reg <= lft_chnnl ^ 16'h8000;		// convert signed to unsigned
	  rght_reg <= rght_chnnl ^ 16'h8000;	// convert signed to unsigned
	end
	
  /////////////////////////////////////
  // Instantiate 16-bit PDM drivers //
  ///////////////////////////////////
  PDM iLft(.clk(clk),.rst_n(rst_n),.duty(lft_reg),.PDM(lft_PDM),.PDM_n(lft_PDM_n));
  PDM iRght(.clk(clk),.rst_n(rst_n),.duty(rght_reg),.PDM(rght_PDM),.PDM_n(rght_PDM_n));
	  
endmodule