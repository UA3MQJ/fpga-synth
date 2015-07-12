module ModuleTester(a, b, c, d);

input wire [7:0] a, b, c;
output wire [15:0] d;

assign d = a + (b * c);

endmodule
