module testbench();

reg [63:0] in_val; 

wire [6:0] out_val;

bit_cntr bcntr(in_val, out_val);

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	in_val <= 64'b0000000000000001001010;
	#100;
	in_val <= 64'b00010000000000001001010;
	#100;
	in_val <= 64'b000000110000000001001010;
	#100;
	in_val <= 64'b1110000000000000001001010;
	#100;
	
    $display("finished OK!");
    $finish;
end
	
endmodule
