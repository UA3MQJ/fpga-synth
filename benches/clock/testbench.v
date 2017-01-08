module testbench();

reg tb_clk;

test01 timer(.clk(tb_clk));

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");

	tb_clk <= 0;
	repeat (10*4000) begin
		#10;
		tb_clk <= 1;
		#10;
		tb_clk <= 0;
	end
	
    $display("finished OK!");
    $finish;
end


	
endmodule
