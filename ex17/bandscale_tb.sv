module band_scale_tb();
reg [11:0]POT;
reg [15:0]audio;
reg [15:0]scaled;



 
band_scale C12315(.POT(POT), .audio(audio), .scaled(scaled));
initial begin
POT=12'd0;
audio=16'd0;
scaled=16'd0;


#20

POT[11:0]=$random;
audio[15:0]=$random;
scaled[15:0]=$random;










end

endmodule