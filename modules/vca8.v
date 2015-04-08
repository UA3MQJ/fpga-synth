module vca8(clk, in, cv, sout);

input wire clk;
input wire [7:0] in, cv;
output reg [7:0] sout;
reg [15:0] result;

always @(posedge clk)
begin
  result = in * cv;
  sout = result[15:8];
end

endmodule