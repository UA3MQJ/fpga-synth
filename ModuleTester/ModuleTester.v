module ModuleTester(clk, out);

parameter WIDTH=7;
parameter LINES=2**WIDTH; //$clog2(WIDTH);

input wire clk;
reg [(LINES-1):0] req;
initial req <= {LINES{1'b0}} + 1'b1;

always @(posedge clk) req <= req << 1;

assign reqs = req;

wire [(LINES-1):0] reqs;
output reg [(WIDTH-1):0] out;

wor [(WIDTH-1):0] result;

genvar gi, gj;
generate
for(gi = 0; gi < LINES; gi = gi + 1 ) begin : bi_gen
	for(gj = 0; gj < WIDTH; gj = gj + 1 ) begin : bj_gen
		if (gi[gj]) begin
			assign result[gj] = reqs[gi];
		end
	end	
end
endgenerate


always @(posedge clk) begin
	out <= result;
end

/*

assign out = (reqs[0])? 3'd0:
				 (reqs[1])? 3'd1:
				 (reqs[2])? 3'd2:
				 (reqs[3])? 3'd3:
				 (reqs[4])? 3'd4:
				 (reqs[5])? 3'd5: 3'd0;


*/

endmodule
