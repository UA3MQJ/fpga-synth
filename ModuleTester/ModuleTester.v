`timescale 1ns / 100ps
`define VectorSize 256
module ModuleTester(
			input wire clk50M,
			input wire key0,
			input wire key1,
			input wire key2,
			input wire key3,
			output wire led0,
			output wire led1,
			output wire [3:0] out_data
);

reg Gtrig;

initial Gtrig <= 1'b0;

assign led0 = Gtrig;

always @(key0 or key1 or key2 or key3) begin
	if ((key0==1'b1)&(key1==1'b1)&(key2==1'b1)&(key3==1'b1)) begin
		Gtrig <= 1'b1;
	end else if ((key0==1'b0)&(key1==1'b0)&(key2==1'b0)&(key3==1'b0)) begin
		Gtrig <= 1'b0;
	end	
end

endmodule
