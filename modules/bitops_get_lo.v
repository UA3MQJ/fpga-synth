module bitops_get_lo(in, out);
parameter width=8;

input wire [(width-1):0] in;
output wire [(width-1):0] out;
wire [(width-1):0] r_data;

bitops_get_hilo_abf gen0_abf(.r(0), .a(in[0]), .out(out[0]), .out_r(r_data[0]));

genvar gi;
generate
for(gi = 1; gi < width; gi = gi + 1 )
begin : bl_generation
	bitops_get_hilo_abf gen_abf(.a(in[gi]), .r(r_data[gi-1]), .out(out[gi]), .out_r(r_data[gi]));
end
endgenerate

endmodule
