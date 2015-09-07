module testbench();

reg tb_clk;

wire out_val;
frqdivmod #(.DIV(3)) div1(tb_clk, out_val);

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	$display("bits for 0..9", $clog2(1));
	
	tb_clk <= 0;
	repeat (20000) begin
		#1;
		tb_clk <= 1;
		#1;
		tb_clk <= 0;
	end
	
    $display("finished OK!");
    $finish;
end
	
endmodule
