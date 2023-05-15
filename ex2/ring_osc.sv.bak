module ring_osc(en,out);
  input en;
  wire n1, n2;
  output out;
  
  nand #5 nand1(n1, en, out);
  not #5 not1(n2, n1);
  not #5 not2(out, n2);  
endmodule
  
