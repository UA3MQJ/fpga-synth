module dds(clk, adder, signal_out);
parameter WIDTH = 32;

input wire clk;
input [(WIDTH - 1):0] adder;

output reg [(WIDTH - 1):0] signal_out;

initial 
begin
	signal_out <= 0;
end

always @(posedge clk) begin
	signal_out <= signal_out + adder;
end


endmodule
