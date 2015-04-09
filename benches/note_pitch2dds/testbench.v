module testbench();

reg [13:0] in_val; //14 bit
reg tb_clk;

wire [31:0] ADDER;
note_pitch2dds dds_adder(tb_clk, 7'd069, in_val, ADDER);


initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");

	in_val = 0;
	
	repeat (16384) begin
		//$display("in=", in_val);

		#20;
		in_val = in_val + 1'b1;		
	end
	
    $display("finished OK!");
    $finish;
end
	
initial
begin
	tb_clk <= 0;
	repeat (200000) begin
		#1;
		tb_clk <= 1;
		#1;
		tb_clk <= 0;
	end
end	
	
endmodule
