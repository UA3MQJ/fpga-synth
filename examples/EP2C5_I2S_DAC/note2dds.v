module note2dds(clk, note, adder);

input wire clk;
input wire [8:0] note; // запас 2 бита. то есть нота не до 127, а до 512!
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
	adder_tbl[ 4'd0] <= 32'd0368205249;
	adder_tbl[ 4'd1] <= 32'd0390099873;
	adder_tbl[ 4'd2] <= 32'd0413296419;
	adder_tbl[ 4'd3] <= 32'd0437872302;
	adder_tbl[ 4'd4] <= 32'd0463909545;
	adder_tbl[ 4'd5] <= 32'd0491495042;
	adder_tbl[ 4'd6] <= 32'd0520720858;
	adder_tbl[ 4'd7] <= 32'd0551684531;
	adder_tbl[ 4'd8] <= 32'd0584489400;
	adder_tbl[ 4'd9] <= 32'd0619244949;
	adder_tbl[ 4'd10] <= 32'd0656067170;
	adder_tbl[ 4'd11] <= 32'd0695078954;	
	adder_tbl[4'd12] <= 32'd0;
	adder_tbl[4'd13] <= 32'd0;
	adder_tbl[4'd14] <= 32'd0;
	adder_tbl[4'd15] <= 32'd0;
end

assign adder = adder_tbl[addr] >> divider;

wire [5:0] diap   = (note <  12) ? 6'd00 :
					     (note <  24) ? 6'd01 :
					     (note <  36) ? 6'd02 :
					     (note <  48) ? 6'd03 :
					     (note <  60) ? 6'd04 :
					     (note <  72) ? 6'd05 :
					     (note <  84) ? 6'd06 :
					     (note <  96) ? 6'd07 :
					     (note < 108) ? 6'd08 :
					     (note < 120) ? 6'd09 : 
					     (note < 132) ? 6'd10 : 
					     (note < 144) ? 6'd11 : 
					     (note < 156) ? 6'd12 : 
					     (note < 168) ? 6'd13 : 
					     (note < 180) ? 6'd14 : 
					     (note < 192) ? 6'd15 : 
					     (note < 204) ? 6'd16 : 
					     (note < 216) ? 6'd17 : 
					     (note < 228) ? 6'd18 : 
					     (note < 240) ? 6'd19 : 
					     (note < 252) ? 6'd20 : 
					     (note < 264) ? 6'd21 : 
					     (note < 276) ? 6'd22 : 
					     (note < 288) ? 6'd23 : 
					     (note < 300) ? 6'd24 : 
					     (note < 312) ? 6'd25 : 
					     (note < 324) ? 6'd26 : 
					     (note < 336) ? 6'd27 : 
					     (note < 348) ? 6'd28 : 
					     (note < 360) ? 6'd29 : 
					     (note < 372) ? 6'd30 : 
					     (note < 384) ? 6'd31 : 
					     (note < 396) ? 6'd32 : 
					     (note < 408) ? 6'd33 : 
					     (note < 420) ? 6'd34 : 
					     (note < 432) ? 6'd35 : 
					     (note < 444) ? 6'd36 : 
					     (note < 456) ? 6'd37 : 
					     (note < 468) ? 6'd38 : 
					     (note < 480) ? 6'd39 : 
					     (note < 492) ? 6'd40 : 
					     (note < 504) ? 6'd41 : 6'd042 ;

wire [6:0] c_addr = note - (diap * 4'd012); 
						 
always @ (posedge clk) begin
	addr    <= c_addr[3:0];
	divider <= 6'd042 - diap;
end

endmodule
