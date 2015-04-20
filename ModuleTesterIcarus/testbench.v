module testbench();

reg clk;
reg [7:0] in_sig;
reg [7:0] in_cv;

initial
begin
	in_sig <= 8'd0;
	in_cv <= 8'd0;
end

wire [7:0] signal_out;
svca vca(clk, in_sig, in_cv, signal_out);

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
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
	repeat (300) begin
		#100;
		in_sig <= 8'd0;
		#100;
		in_sig <= 8'b11111111; 
	end
end

initial
begin
	repeat (1024) begin
		#80;
		in_cv <= in_cv + 1'b1;
	end
end

	
endmodule
