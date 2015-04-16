module reg32(clk, wr, data, data_out);

input wire clk;
input wire [31:0] data;
input wire wr;
output reg [31:0] data_out;

initial begin
	data_out <= 32'd0;
end

always @ (posedge clk) begin
	if (wr==1) begin
		data_out <= data;
	end
end

endmodule
