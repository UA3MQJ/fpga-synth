module reg_rs(clk, s, r, data_out);

input wire clk;
input wire s;
input wire r;
output reg data_out;

initial begin
	data_out <= 0;
end

always @ (posedge clk) begin
	if (s==1) begin
		data_out <= 1;
	end else if (r==1) begin
		data_out <= 0;
	end	
end

endmodule
