module rndx(clk, signal_out);
parameter WIDTH = 1; // 1..32 
parameter [31:0] INIT_VAL = 32'h12345678;

input wire clk;
output reg [(WIDTH - 1):0] signal_out;

reg [(WIDTH - 1):0] tsout;

reg [31:0] dx [(WIDTH - 1):0];

integer i;


reg [31:0] init_val;
initial
begin
	signal_out <= 8'd0;
	tsout <= 8'd0;
	init_val = INIT_VAL;
	for(i=0; i<WIDTH ; i=i+1) begin
		dx[i] <= init_val; //32'd0123; //$random;
		init_val = init_val << 1 + init_val[31];
	end
end

always @(posedge clk) begin 
	for(i=0; i<WIDTH ; i=i+1) begin
		dx[i] <= { dx[i][30:0], dx[i][30] ^ dx[i][27] };
		tsout = (tsout << 1) + dx[i][5:5];
	end
	signal_out <= tsout;
end

endmodule
/* examples
wire [7:0] rnd8_1;
rndx #(.WIDTH(8), .INIT_VAL(32'hF1928374)) rnd_8_1(.clk(clk), .sout(rnd8_1));
wire [7:0] rnd8_2;
rndx #(.WIDTH(8), .INIT_VAL(32'hF5729465)) rnd_8_2(.clk(clk), .sout(rnd8_2));
wire [7:0] rnd8_3;
rndx #(.WIDTH(8), .INIT_VAL(32'h853F4658)) rnd_8_3(.clk(clk), .sout(rnd8_3));

wire rnd1;
rndx rnd_1(.clk(clk), .sout(rnd1)); //1 bit by default
*/