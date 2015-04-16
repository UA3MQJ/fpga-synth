module dds(clk, add, sout);
parameter WIDTH = 32;

input wire clk;
input [(WIDTH - 1):0] add;

output reg [(WIDTH - 1):0] sout;

initial 
begin
	sout <= 0;
end

always @(posedge clk) begin
	sout <= sout + add;
end


endmodule
