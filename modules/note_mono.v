module note_mono(clk, rst, note_on, note_off, note, out_note, out_gate);			   				   

parameter WIDTH=8;
parameter WIDTH_BIT=ceil(log2(WIDTH));

//inputs outputs
input wire clk, rst, note_on, note_off;
input wire [6:0] note;
output wor [6:0] out_note;
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
wire [127:0] keys_hi;
bitops_get_hi #(.width(128)) get_test1(.in(keys), .out(keys_hi));
//priority encoder
genvar gi;
generate
for(gi = 0; gi < 128; gi = gi + 1 )
begin : bl_generation_h
	assign out_note = (keys_hi[gi]) ? gi : 4'd0;
end
endgenerate

 

endmodule
