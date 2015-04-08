module dds32(clk, add, sout);

input wire clk;
input [31:0] add;

output reg [31:0] sout;

initial 
begin
	sout <= 0;
end

always @(posedge clk) begin
	sout <= sout + add;
end


endmodule
