module bitops_get_hi(in, out);
parameter width=8;

input wire [(width-1):0] in;
output wire [(width-1):0] out;
wire [(width-1):0] r_data;

bitops_get_hilo_abf gen0_abfh(.r(0), .a(in[width-1]), .out(out[width-1]), .out_r(r_data[width-1]));

genvar gi;
generate
for(gi = 1; gi < width; gi = gi + 1 )
begin : bl_generation_h
	bitops_get_hilo_abf gen_abf(.a(in[width-1-gi]), .r(r_data[width-gi]), .out(out[width-1-gi]), .out_r(r_data[width-1-gi]));
end
endgenerate

endmodule
