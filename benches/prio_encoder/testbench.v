`timescale 1us / 100 ps

module testbench();

parameter WIDTH=128;

reg [(WIDTH-1):0] in_vect;
wire [(WIDTH-1):0] in_data;
assign in_data = in_vect;

wire [6:0] out_data;

wire [(WIDTH-1):0] in_data_wbs; //with bit scan

bitscan #(.WIDTH(128)) bs0(.in(in_data), .out(in_data_wbs));
prio_encoder #(.LINES(128)) pe0(.in(in_data), .out(out_data));

integer i;

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	in_vect <= 128'd0;
		#10;
	in_vect <= 128'd1;
	i <= 1;
	repeat (WIDTH) begin
		#10;
		in_vect <= in_vect << 1;
		i <= i + 1;
		//$display("i=", i, i % 4);
		
		
	end
	
    $display("finished OK!");
end

endmodule