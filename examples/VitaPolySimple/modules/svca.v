// not signed, symmetric max/2
module svca(in, cv, signal_out); //
parameter WIDTH = 8; //

input wire [(WIDTH-1):0] in, cv;
output wire [(WIDTH-1):0] signal_out;


wire signed [(WIDTH):0] s_in = in - 8'd128; // 0..255 -> signed -128..127
wire signed [(WIDTH):0] s_cv = cv;

wire signed [(WIDTH*2):0] result_s = s_in * s_cv;
wire signed [(WIDTH*2):0]   result_ss = result_s >>> 8;
wire [(WIDTH*2):0]   result_sss = result_ss + 8'd128;
assign signal_out = result_sss[(WIDTH-1):0];

endmodule
