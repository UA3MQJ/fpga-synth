module testbench();

reg clk;

wire div5, div13;
div_5_13 div1(.clk(clk), .div5(div5), .div13(div13));

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
		

	clk <= 0;
	repeat (1000) begin
		#10;
		clk <= 1;
		#10;
		clk <= 0;
	end
	
    $display("finished OK!");
    $finish;
end


	
endmodule
