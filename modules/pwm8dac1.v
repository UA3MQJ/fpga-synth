module pwm8dac1(clk, in_data, sout);
			
input clk; 
input [7:0] in_data; 
output reg sout;			

reg [7:0] cnt;

initial begin
	cnt <= 8'd0;
	sout <= 0;
end

always @(posedge clk) begin
	if ((in_data==8'd0)) begin
		sout <= 0;
	end else begin
		cnt  <= cnt + 1'b1;
		sout <= (in_data>cnt);
	end
end

endmodule
