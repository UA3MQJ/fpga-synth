module rnd8(clk, sout);

input wire clk;
output reg [7:0] sout;

reg [31:0] d0;
reg [31:0] d1;
reg [31:0] d2;
reg [31:0] d3;
reg [31:0] d4;
reg [31:0] d5;
reg [31:0] d6;
reg [31:0] d7;

initial
begin
  sout <= 8'd0;
  d0 <= 31'b0011010100100100110010101110010;
  d1 <= 31'b0101010101010010101010010110010;
  d2 <= 31'b0101010010101010101010100101010;
  d3 <= 31'b0101010011001100101010110010101;
  d4 <= 31'b0101010010101010101011001010110;
  d5 <= 31'b1001001011001010100101101010100;
  d6 <= 31'b0101010100100110100101010101010;
  d7 <= 31'b0101010010101010110100101010101;
end

always @(posedge clk) begin 
	d0 <= { d0[30:0], d0[30] ^ d0[27] };
	d1 <= { d1[30:0], d1[30] ^ d1[27] };
	d2 <= { d2[30:0], d2[30] ^ d2[27] };
	d3 <= { d3[30:0], d3[30] ^ d3[27] };
	d4 <= { d4[30:0], d4[30] ^ d4[27] };
	d5 <= { d5[30:0], d5[30] ^ d5[27] };
	d6 <= { d6[30:0], d6[30] ^ d6[27] };
	d7 <= { d7[30:0], d7[30] ^ d7[27] };
	
	sout <= {d0[5:5],d1[5:5],d2[5:5],d3[5:5],d4[5:5],d5[5:5],d6[5:5],d7[5:5]};

end

endmodule