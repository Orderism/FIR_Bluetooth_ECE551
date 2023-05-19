 module band_scale_rnd_tb();

logic [27:0]memory_stim[1000:0];
logic [17:0]memory_resp[1000:0];
logic [11:0]POT;
logic [15:0]audio;  
logic [15:0]scaled;
logic clk;
integer k;
integer i;

//Stim[27:16] to POT[11:0]
//Stim[15:0] to audio[15:0]

initial begin

clk=0;
//open will there need an open operation for the file?
//file = $fopen("compare.txt", ?r? );

//read
$readmemh ("band_scale_stim.hex", memory_stim);// read the memory_stim from txt


//split the memory_stim into 2 memorys
fork
    for (i = 0; i < 1000; i=i+1) begin
        @(posedge clk)
        {POT,audio}=memory_stim[i];
    end
/*
    for(audio[j])for(j = 0; j < 1000; j=j+1) begin
        @(posedge clk)
        audio[j]=$memory_stim(j) [15:0];
    end    
*/
//write the result back to the response mem
    for (k = 0; k < 1000; k=k+1) begin
//foreach (memory_resp[k]) begin
//could we use the foreacH?
        @(posedge clk)
        memory_resp[k]=scaled;//send result to the response mem
    end
join

//write the data in mem into the file
    $writememb("band_scale_resp.hex", memory_resp);
end


band_scale C12315( .POT(POT), .audio(audio), .scaled(scaled));///???


always#5 clk=~clk;
endmodule