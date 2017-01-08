module reg1(data, wr, data_out);

input wire data;
input wire wr;
output reg data_out;

initial begin
	data_out <= 0;
end

always @ (posedge wr) begin
	data_out <= data;
end

endmodule
