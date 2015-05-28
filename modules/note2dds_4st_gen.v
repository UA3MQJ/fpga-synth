module note2dds_4st_gen(clk, note, adder);

input wire clk;
input wire [6:0] note;
output [31:0] adder;

reg [31:0] adder_tbl [15:0];
reg [3:0] addr;
reg [3:0] divider;

// note div 12 ( * 0,08333333333333333333333333333333)
//; Add input / 16 to accumulator
//; Add input / 64 to accumulator

initial begin
   addr <= 4'd0;
	divider <= 4'd0;
	adder_tbl[ 4'd0] <= 32'd0359575;
	adder_tbl[ 4'd1] <= 32'd0380957;
	adder_tbl[ 4'd2] <= 32'd0403610;
	adder_tbl[ 4'd3] <= 32'd0427610;
	adder_tbl[ 4'd4] <= 32'd0453037;
	adder_tbl[ 4'd5] <= 32'd0479976;
	adder_tbl[ 4'd6] <= 32'd0508516;
	adder_tbl[ 4'd7] <= 32'd0538754;
	adder_tbl[ 4'd8] <= 32'd0570790;
	adder_tbl[ 4'd9] <= 32'd0604731;
	adder_tbl[4'd10] <= 32'd0640691;
	adder_tbl[4'd11] <= 32'd0678788;
	adder_tbl[4'd12] <= 32'd0;
	adder_tbl[4'd13] <= 32'd0;
	adder_tbl[4'd14] <= 32'd0;
	adder_tbl[4'd15] <= 32'd0;
end

assign adder = adder_tbl[addr] >> divider;

wire [3:0] diap   = (note <  12) ? 4'd00 :
					     (note <  24) ? 4'd01 :
					     (note <  36) ? 4'd02 :
					     (note <  48) ? 4'd03 :
					     (note <  60) ? 4'd04 :
					     (note <  72) ? 4'd05 :
					     (note <  84) ? 4'd06 :
					     (note <  96) ? 4'd07 :
					     (note < 108) ? 4'd08 :
					     (note < 120) ? 4'd09 : 4'd010 ;

wire [6:0] c_addr = note - (diap * 4'd012); 
						 
always @ (posedge clk) begin
	addr    <= c_addr[3:0];
	divider <= 4'd010 - diap;
end

endmodule
