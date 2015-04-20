module vca8(clk, in, cv, signal_out);

input wire clk;
input wire [7:0] in, cv;
output reg [7:0] signal_out;
reg [15:0] result;

always @(posedge clk)
begin
  result = in * cv;
  signal_out = result[15:8];
end

endmodule
