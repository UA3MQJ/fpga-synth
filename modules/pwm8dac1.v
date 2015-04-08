module pwm8dac1(clk, in_data, sout);
			
input clk; 
input [7:0] in_data; 
output reg sout;			
reg [7:0] in_data_buff; 

reg [7:0] cnt;

initial cnt = 0;

always @(posedge clk) begin
	cnt <= cnt + 1'b1;  // free-running counter
	in_data_buff <= in_data;
end

//assign sout = (in_data>cnt);  // comparator

always @(negedge clk) begin
	sout <= (in_data_buff>cnt);
end


endmodule
