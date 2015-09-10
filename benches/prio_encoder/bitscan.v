module bitscan (in,out); //revered bit scan. rearch hi setted bit
parameter WIDTH = 16;
input wire [WIDTH-1:0] in;
output wire [WIDTH-1:0] out;

wire [WIDTH-1:0] in_rev;
wire [WIDTH-1:0] out_rev;

genvar gi;
generate
for(gi = 0; gi < WIDTH; gi = gi + 1 )
begin : bl_generation_h
	assign out[WIDTH-1-gi] = out_rev[gi];
	assign in_rev[WIDTH-1-gi] = in[gi];
end
endgenerate

assign out_rev = in_rev & ~(in_rev-1);

endmodule
