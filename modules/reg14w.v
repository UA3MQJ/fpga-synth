module reg14w(clk, wr, data, data_out);

input wire clk;
input wire [13:0] data;
input wire wr;
output reg [13:0] data_out;

initial begin
	data_out <= 14'd0;
end

always @ (posedge clk) begin
	if (wr==1) begin
		data_out <= data;
	end
end

endmodule
