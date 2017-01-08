module testbench();

reg clkA;
reg clkB;
reg flagIN;
reg [7:0] dataIN;

initial begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	
	clkB <= 0; 
	repeat (20) begin
		#571;
		clkB <= 1;
		#571;
		clkB <= 0; 
	end
	
    $display("finished OK!");
    $finish;
end

initial begin
	clkA <= 0; 

	repeat (20*29) begin
		#20;
		clkA <= 1;
		#20;
		clkA <= 0; 
	end
end

initial begin
	dataIN <= 8'd0;
	flagIN <= 0;
	#180;
	dataIN <= 8'd066;
	flagIN <= 1;
	#40;
	dataIN <= 8'd0;
	flagIN <= 0;
	#7000;
	dataIN <= 8'd0120;
	flagIN <= 1;
	#40;
	dataIN <= 8'd0;
	flagIN <= 0;
end

wire flagOut;
wire  [7:0] dataOUT;
Data_CrossDomain fck(clkA, flagIN, clkB, flagOut, dataIN, dataOUT);
	
endmodule
