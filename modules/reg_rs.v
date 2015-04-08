module reg_rs(CLK, S, R, DOUT);

input wire CLK;
input wire S;
input wire R;
output reg DOUT;

initial begin
	DOUT <= 0;
end

always @ (posedge CLK) begin
	if (S==1) begin
		DOUT <= 1;
	end else if (R==1) begin
		DOUT <= 0;
	end	
end

endmodule