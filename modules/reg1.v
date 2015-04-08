module reg1(DATA, WR, DATA_OUT);

input wire DATA;
input wire WR;
output reg DATA_OUT;

initial begin
	DATA_OUT <= 0;
end

always @ (posedge WR) begin
	DATA_OUT <= DATA;
end

endmodule