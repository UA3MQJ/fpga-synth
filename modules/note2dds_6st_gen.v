module note2dds_6st_gen(clk, note, adder);

input wire clk;
input wire [6:0] note;
output [31:0] adder;

reg [3:0] addr;
reg [3:0] divider;
wire [31:0] adder_tbl;

// note div 12 ( * 0,08333333333333333333333333333333)
//; Add input / 16 to accumulator
//; Add input / 64 to accumulator

note2dds_rom note2dds_rom0(.address(addr),
								   .clock(clk),
									.q(adder_tbl));

initial begin
   addr <= 4'd0;
	divider <= 4'd0;
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
