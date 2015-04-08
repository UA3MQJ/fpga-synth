module reg14(CLK, WR_LSB, WR_MSB, DATA, DATA_OUT);

input wire CLK;
input wire [6:0] DATA;
input wire WR_LSB, WR_MSB;
output reg [13:0] DATA_OUT;

initial begin
	DATA_OUT <= 7'd0;
end

always @ (posedge CLK) begin
	if (WR_LSB==1) begin
		DATA_OUT[6:0] <= DATA;
	end else if (WR_MSB==1) begin
		DATA_OUT[13:7] <= DATA;
	end
end

endmodule