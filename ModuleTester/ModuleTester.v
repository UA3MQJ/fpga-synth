`timescale 1ns / 100ps

module ModuleTester(
			input wire clk50M,
			input wire key0,
			input wire key1,
			input wire key2,
			input wire key3,
			output wire led0,
			output wire led1,
			input wire [7:0] in_data,
			output reg [7:0] out_data
);

initial out_data <= 8'd0;

parameter SIZE = 128;
reg [SIZE-1:0] arr;

initial arr <= 128'd0;

always @(posedge clk50M) arr <= arr + 1'b1;

integer i;
always @(posedge clk50M)
begin
	out_data = 8'd0;
	for(i=0;i<SIZE;i=i+1) begin
		if (arr[i]==1) begin
			out_data = i;
		end
	end
end

endmodule
