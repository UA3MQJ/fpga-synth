module prio_encoder(in, out);

parameter LINES=128; //$clog2(WIDTH);2**WIDTH back transform
parameter WIDTH=$clog2(LINES);

input wire [(LINES-1):0] in;
output wor [(WIDTH-1):0] out;

genvar gi, gj;
generate
for(gi = 0; gi < LINES; gi = gi + 1 ) begin : bi_gen
	for(gj = 0; gj < WIDTH; gj = gj + 1 ) begin : bj_gen
		if (gi[gj]) begin
			assign out[gj] = in[gi];
		end
	end	
end
endgenerate

endmodule
