module testbench();

reg tb_clk;
reg SCK;
reg MOSI;
reg SSEL;
wire MISO;
wire [7:0] MSG;

spi_slave spi1(.CLK(tb_clk),
               .SCK(SCK), 
			   .MOSI(MOSI), 
			   .MISO(MISO), 
			   .SSEL(SSEL),
			   .MSG(MSG));

initial
begin
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");

	tb_clk <= 0;
	repeat (10*100) begin
		#1;
		tb_clk <= 1;
		#1;
		tb_clk <= 0;
	end
	
    $display("finished OK!");
    $finish;
end


reg [15:0] msg;
initial
begin
	SSEL <= 1;
	SCK <= 0;
	MOSI <= 0;
	msg <= 16'b1110001101010101;
	#100;
	SSEL <= 0;
	repeat (16) begin
		#10;
		MOSI <= msg[15];
		msg <= msg << 1;
		SCK <= 1;
		#10;
		SCK <= 0;
		
	end	
	SSEL <= 1;
	
end	

reg a, b;
wand WA;

assign WA = a;
assign WA = b;

initial begin
	a <= 1'bz;
	b <= 1'bz;
	#100;
	a <= 1;
	#100;
	a <= 1'bz;
	#100;
	b <= 1;
	#100;
	b <= 1'bz;

	#100;
	a <= 0;
	#100;
	a <= 1'bz;
	#100;
	b <= 0;
	#100;
	b <= 1'bz;

	#100;
	a <= 0;
	b <= 0;
	#100;
	a <= 1'bz;
	b <= 1'bz;
	
	#100;
	a <= 1;
	b <= 1;
	#100;
	a <= 1'bz;
	b <= 1'bz;

	#100;
	a <= 0;
	b <= 1;
	#100;
	a <= 1'bz;
	b <= 1'bz;
	
	#100;
	a <= 1;
	b <= 0;
	#100;
	a <= 1'bz;
	b <= 1'bz;
	

	
end

	
endmodule
