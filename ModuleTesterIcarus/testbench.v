module testbench();

reg clk;
reg get;

fgl fgl1(.clk(clk), .get(get));

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	clk <= 0; 
	repeat (3000) begin
		#10;
		clk <= 1;
		#10;
		clk <= 0; 
	end
	
    $display("finished OK!");
    //$finish;
end

initial
begin
	get <= 0;
	#100;
	get <= 1;
	#25;
	get <= 0;

	#100;
	get <= 1;
	#25;
	get <= 0;

	#100;
	get <= 1;
	#25;
	get <= 0;

	#100;
	get <= 1;
	#25;
	get <= 0;

	#100;
	get <= 1;
	#25;
	get <= 0;

	#100;
	get <= 1;
	#25;
	get <= 0;

	#100;
	get <= 1;
	#25;
	get <= 0;
	
	
end

	
endmodule
