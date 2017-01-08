module testbench();

reg clk;

wire [11:0] out;

wire out1;
reg [7:0] period;

frqdivmod  #(.DIV(3)) div1(.clk(clk), .s_out(out1));

//div3
reg [1:0] d3_r; initial d3_r <= 2'd0;
always @ (posedge clk) begin
	d3_r <= (d3_r==2'd2) ? 2'd0 : d3_r + 1'b1;
end
wire res_d3 = (d3_r==2'd0);

initial
begin
	period <= 8'd0;
    $dumpfile("bench.vcd");
    $dumpvars(0,testbench);

    $display("starting testbench!!!!");
	
	

	clk <= 0;
	repeat (1000) begin
		#10;
		clk <= 1;
		#10;
		clk <= 0;
		period <= period + 1'b1;
	end
	
    $display("finished OK!");
    $finish;
end


	
endmodule
