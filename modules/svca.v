// not signed, symmetric max/2
module svca(clk, in, cv, signal_out); //
parameter WIDTH = 8; //

input wire clk;
input wire [(WIDTH-1):0] in, cv;
output reg [(WIDTH-1):0] signal_out;
reg signed [((WIDTH*2)-1):0] result;

wire signed [(WIDTH-1):0] s_in = in - 128; // 0..255 -> signed -128..127
wire signed [(WIDTH-1):0] s_cv = cv >> 1;

always @(posedge clk)
begin
  result = s_in * s_cv;
  signal_out = 128 - (result >>> 7);
end

endmodule
