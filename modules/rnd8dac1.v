module rnd8dac1(clk, in_data, sout);
input clk;
input [7:0] in_data;
output wire sout;

reg [7:0] sig;

wire [7:0] rnd_sout;
rnd8 rnd_src(clk, rnd_sout);

assign sout = (rnd_sout<sig);

always @(posedge clk) begin
	sig <= in_data;
end

endmodule
