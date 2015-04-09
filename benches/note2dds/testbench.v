module testbench();

reg [6:0] in_val; //7 bit
reg tb_clk;

wire [31:0] ADDER;
note2dds dds_adder(tb_clk, in_val, ADDER);

// note div 12 ( * 0,08333333333333333333333333333333)
//; Add input / 16 to accumulator >>>  4
//; Add input / 64 to accumulator >>>  6
//; Add input / 256 to accumulator >>> 8
//; Add input / 1024 to accumulator >>> 10
//муть, проще сделать case

wire [3:0] x_div12 = (in_val <  12) ? 0 :
					 (in_val <  24) ? 1 :
					 (in_val <  36) ? 2 :
					 (in_val <  48) ? 3 :
					 (in_val <  60) ? 4 :
					 (in_val <  72) ? 5 :
					 (in_val <  84) ? 6 :
					 (in_val <  96) ? 7 :
					 (in_val < 108) ? 8 :
					 (in_val < 120) ? 9 : 10 ;

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");

	in_val = 0;
	
	repeat (128) begin
		#20;
		$display("in=", in_val, " div 12 = ", x_div12, " mod12 = ", );

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
