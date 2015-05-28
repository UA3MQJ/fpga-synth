module note2dds_5st_gen(clk, note, adder);

input wire clk;
input wire [6:0] note;
output [31:0] adder;

(* romstyle = "logic" *) reg [31:0] table_values;

reg [4:0] addr_reg;

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
wire [3:0] divider = 4'd010 - diap;

always@(posedge clk) begin
   addr_reg <= c_addr[3:0];
   case(addr_reg)
		4'd00: table_values <= 32'd0359575;
		4'd01: table_values <= 32'd0380957;
		4'd02: table_values <= 32'd0403610;
		4'd03: table_values <= 32'd0427610;
		4'd04: table_values <= 32'd0453037;
		4'd05: table_values <= 32'd0479976;
		4'd06: table_values <= 32'd0508516;
		4'd07: table_values <= 32'd0538754;
		4'd08: table_values <= 32'd0570790;
		4'd09: table_values <= 32'd0604731;
		4'd10: table_values <= 32'd0640691;
		4'd11: table_values <= 32'd0678788;
		4'd12: table_values <= 32'd0;
		4'd13: table_values <= 32'd0;
		4'd14: table_values <= 32'd0;
		4'd15: table_values <= 32'd0;
	endcase
end  

assign adder = table_values >> divider; 

endmodule
