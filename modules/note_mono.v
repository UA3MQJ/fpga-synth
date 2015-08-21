module note_mono(clk, rst, note_on, note_off, note, out_note, out_gate);			   				   

//inputs outputs
input wire clk, rst, note_on, note_off;
input wire [6:0] note;
output wire [6:0] out_note;
output wor out_gate;

reg [127:0] keys;
initial keys <= 128'd0;

//store keys to array
always @(posedge clk) begin
	if (rst) begin
		keys <= 128'd0;
	end else if (note_on) begin
		keys[note] <= 1'b1;
	end else if (note_on) begin
		keys[note] <= 1'b0;
	end
end

//generate out_gate - = 1 where at least one bit is set
genvar i;
generate
	for(i=0;i<128;i=i+1'b1) 
	begin : gn
		assign out_gate = keys[i];
	end
endgenerate

//generate hign key nubmer


endmodule
