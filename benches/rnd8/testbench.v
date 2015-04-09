module testbench();

reg [6:0] in_val; //7 bit
reg tb_clk;

wire [7:0] out_val;
rnd8 rnd8_gen(tb_clk, out_val);

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	tb_clk <= 0;
	repeat (2000) begin
		#1;
		tb_clk <= 1;
		#1;
		tb_clk <= 0;
	end
	
    $display("finished OK!");
    $finish;
end
	
endmodule
