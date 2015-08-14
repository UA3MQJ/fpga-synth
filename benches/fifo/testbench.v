module testbench();

reg clk;
reg [7:0] in_data;
reg in_d_rdy;
reg rdy2rcv;
reg rdy2rcv_b;

wire [7:0] out_data;
wire out_d_rdy;

fifo buff01(.clk(clk), .in_data(in_data), .in_d_rdy(in_d_rdy), .rdy2rcv(rdy2rcv_b),
			.out_data(out_data), .out_d_rdy(out_d_rdy));

initial begin
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
    $finish;
end

initial begin
	in_data <= 8'd0;
	in_d_rdy <= 0;
	repeat (20) begin
		#200;
		in_d_rdy <= 1;
		in_data <= in_data + 1'b1;
		#20;
		in_d_rdy <= 0;
	end
	in_data <= 8'd0;
	in_d_rdy <= 0;	
end

always @(posedge clk) rdy2rcv_b<=rdy2rcv;

initial begin
	rdy2rcv <= 1;
	#1100;
	rdy2rcv <= 0;
	#1000;
	rdy2rcv <= 1;
	#1000;
	rdy2rcv <= 0;
	#2000;
	rdy2rcv <= 1;
end
	
endmodule
