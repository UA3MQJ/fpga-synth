module rnd8dac1(clk, sig_in, sig_out);
input clk;
input [7:0] sig_in;
output wire sig_out;

reg [7:0] sig;

wire [7:0] rnd_sout;
rnd8 rnd_src(clk, rnd_sout);

assign sig_out = (rnd_sout<sig);

always @(posedge clk) begin
	sig <= sig_in;
end

endmodule
