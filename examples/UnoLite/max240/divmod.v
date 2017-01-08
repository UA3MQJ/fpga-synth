module divmod(clk, max_val, out_clk);
input wire clk;
input wire [9:0] max_val;
output wire out_clk;

reg [9:0] d1_counter; initial d1_counter <= 10'd0;

always @ (posedge clk) d1_counter <= (d1_counter==10'd0) ? max_val : d1_counter - 1'b1;

assign out_clk = (d1_counter==2'd0);

endmodule
