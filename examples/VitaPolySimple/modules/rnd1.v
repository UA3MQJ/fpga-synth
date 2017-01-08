module rnd1(clk, sout);

input wire clk;
output reg sout;

reg [31:0] d0;

initial
begin
  d0 <= 31'b0011010100100100110010101110010;
  sout <= 0;
end

always @(posedge clk) begin 
	d0 <= { d0[30:0], d0[30] ^ d0[27] };
	sout <= d0[5:5];
end

endmodule
