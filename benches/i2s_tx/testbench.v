module testbench();

reg tb_clk;

reg [31:0] l_reg;
reg [31:0] r_reg;


wire [31:0] l_data;
wire [31:0] r_data;

assign l_data = l_reg;
assign r_data = r_reg;

wire LRCK, DAT, MCK, SCK;
//i2s_tx #(.DATA_WIDTH(16), .MCLK_DIV(2), .FS(128)) iis_tx( 
i2s_tx #(.DATA_WIDTH(32)) iis_tx( 
							   .clk(tb_clk),
							   .left_chan(l_data),
							   .right_chan(r_data),
							   .sdata(DAT),
							   .mck(MCK),
							   .sck(SCK),
							   .lrclk(LRCK)
							   );


reg [7:0] ccc;

wire signed [7:0] ccc_s = ccc - 8'b10000000;
							   
initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
    $display("$clog2(2)", $clog2(2+1));
    $display("$clog2(4)", $clog2(4+1));
    $display("$clog2(6)", $clog2(6+1));
    $display("$clog2(8)", $clog2(8+1));
    $display("$clog2(10)", $clog2(10+1));
	
	l_reg <= 32'b10000000000000000000000000000001;
	r_reg <= 32'b10101011010101011010101101010101;
	tb_clk <= 0;
	
	tb_clk <= 0;
	ccc <=0;
	repeat (10*4000) begin
		#10;
		tb_clk <= 1;
		ccc <= ccc +1'b1;
		#10;
		tb_clk <= 0;
		ccc <= ccc +1'b1;
		#10;
		tb_clk <= 1;
		ccc <= ccc +1'b1;
		#10;
		tb_clk <= 0;
		ccc <= ccc +1'b1;
		
	end
	
    $display("finished OK!");
    $finish;
end


	
endmodule
