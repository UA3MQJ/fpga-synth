module note2dds_2st_gen(CLK, NOTE, ADDER);

input wire CLK;
input wire [6:0] NOTE;
output reg [31:0] ADDER;

reg [31:0] ADDER_tbl [12:0];
// note div 12 ( * 0,08333333333333333333333333333333)
//; Add input / 16 to accumulator
//; Add input / 64 to accumulator

initial begin
	ADDER_tbl[ 4'd0] <= 32'd0359575;
	ADDER_tbl[ 4'd1] <= 32'd0380957;
	ADDER_tbl[ 4'd2] <= 32'd0403610;
	ADDER_tbl[ 4'd3] <= 32'd0427610;
	ADDER_tbl[ 4'd4] <= 32'd0453037;
	ADDER_tbl[ 4'd5] <= 32'd0479976;
	ADDER_tbl[ 4'd6] <= 32'd0508516;
	ADDER_tbl[ 4'd7] <= 32'd0538754;
	ADDER_tbl[ 4'd8] <= 32'd0570790;
	ADDER_tbl[ 4'd9] <= 32'd0604731;
	ADDER_tbl[4'd10] <= 32'd0640691;
	ADDER_tbl[4'd11] <= 32'd0678788;
end

always @ (posedge CLK) begin
	if (NOTE <  12) begin
		//? 0 :
		ADDER <= (ADDER_tbl[NOTE]) >> 10;
	end else if (NOTE <  24) begin
		//? 1 :
		ADDER <= (ADDER_tbl[NOTE - 12]) >> 9;
	end else if (NOTE <  36) begin
		//? 2 :
		ADDER <= (ADDER_tbl[NOTE - 24]) >> 8;
	end else if (NOTE <  48) begin
		//? 3 :
		ADDER <= (ADDER_tbl[NOTE - 36]) >> 7;
	end else if (NOTE <  60) begin
		//? 4 :
		ADDER <= (ADDER_tbl[NOTE - 48]) >> 6;
	end else if (NOTE <  72) begin
		//? 5 :
		ADDER <= (ADDER_tbl[NOTE - 60]) >> 5;
	end else if (NOTE <  84) begin
		//? 6 :
		ADDER <= (ADDER_tbl[NOTE - 72]) >> 4;
	end else if (NOTE <  96) begin
		//? 7 :
		ADDER <= (ADDER_tbl[NOTE - 84]) >> 3;
	end else if (NOTE < 108) begin
		//? 8 :
		ADDER <= (ADDER_tbl[NOTE - 96]) >> 2;
	end else if (NOTE < 120) begin
		//? 9 : 
		ADDER <= (ADDER_tbl[NOTE - 108]) >> 1;
	end else begin
		//10 ;
		ADDER <= (ADDER_tbl[NOTE - 120]);
	end
end

endmodule
