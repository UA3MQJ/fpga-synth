module testbench();

reg clk;

reg key;

wire reset_sig;

powerup_reset RS_GEN(.key(key), .clk(clk), .rst(reset_sig));

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	repeat (300) begin
		#10;
		clk <= 1;
		#10;
		clk <= 0; 
	end
	
    $display("finished OK!");
    $finish;
end

initial
begin
	#1900;
	key <= 1;
	#90;
	key <= 0;
end
	
endmodule
