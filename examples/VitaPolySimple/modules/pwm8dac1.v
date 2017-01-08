module pwm8dac1(clk, in_data, sout);
			
input clk; 
input [7:0] in_data; 
output reg sout;
reg [7:0] saved_data;

reg [7:0] cnt;

initial begin
	cnt <= 8'd0;
	sout <= 0;
	saved_data <= 8'd0;
end

always @(posedge clk) begin
	cnt  <= cnt + 1'b1;
	sout <= (saved_data>cnt);
	if (cnt==8'd0) begin
   	saved_data <= in_data;
	end
end

endmodule
