module pwm8dac1 #
   (
   parameter width = 8
   )
	(clk, in_data, sout);
			
input clk; 
input [width-1:0] in_data; 
output reg sout;
reg [width-1:0] saved_data;

reg [width-1:0] cnt;

initial begin
	cnt <= {width{1'b0}};
	sout <= 0;
	saved_data <= {width{1'b0}};
end

always @(posedge clk) begin
	cnt  <= cnt + 1'b1;
	sout <= (saved_data>cnt);
	if (cnt=={width{1'b0}}) begin
   	saved_data <= in_data;
	end
end

endmodule
