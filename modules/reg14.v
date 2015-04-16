module reg14(clk, wr_lsb, wr_msb, data, data_out);

input wire clk;
input wire [6:0] data;
input wire wr_lsb, wr_msb;
output reg [13:0] data_out;

initial begin
	data_out <= 7'd0;
end

always @ (posedge clk) begin
	if (wr_lsb==1) begin
		data_out[6:0] <= data;
	end else if (wr_msb==1) begin
		data_out[13:7] <= data;
	end
end

endmodule
