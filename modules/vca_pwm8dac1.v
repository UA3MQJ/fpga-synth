module vca_pwm8dac1(clk, in_data, sout);
			
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
		if (saved_data<in_data) begin
			saved_data <= saved_data + 1'b1;
		end else if (saved_data>in_data) begin
			saved_data <= saved_data - 1'b1;
		end
	end
end

endmodule
