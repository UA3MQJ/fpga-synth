module ModuleTester(clk, out);

parameter WIDTH=7;
input wire clk;
output wire [(WIDTH-1):0] out;

reg [127:0] indat;
initial indat <= 128'd1;

always @(posedge clk) indat <= indat << 1;


wire [127:0] indat_wbs;
bitscan #(.WIDTH(128)) bs0(.in(indat), .out(indat_wbs));
prio_encoder #(.LINES(128)) pe0(.in(indat_wbs), .out(out));


endmodule
