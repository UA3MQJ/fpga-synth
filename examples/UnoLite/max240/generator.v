module generator(clk, out1, out2, out3, out4, out5, out6,out7,out8);

input wire clk;

output wire out1,out2,out3,out4,out5,out6,out7,out8;


reg [129:0] d1_max;     initial d1_max <= 130'd956;

divmod div1(.clk(clk), .max_val(d1_max[ 9: 0]), .out_clk(out1));
divmod div2(.clk(clk), .max_val(d1_max[19:10]), .out_clk(out2));
divmod div3(.clk(clk), .max_val(d1_max[29:20]), .out_clk(out3));
divmod div4(.clk(clk), .max_val(d1_max[39:30]), .out_clk(out4));
divmod div5(.clk(clk), .max_val(d1_max[49:40]), .out_clk(out5));
divmod div6(.clk(clk), .max_val(d1_max[59:50]), .out_clk(out6));
divmod div7(.clk(clk), .max_val(d1_max[69:60]), .out_clk(out7));
divmod div8(.clk(clk), .max_val(d1_max[79:70]), .out_clk(out8));

always @ (posedge clk) d1_max <= d1_max + 1'b1;

//frqdivmod  #(.DIV(73)) div1(.clk(clk), .s_out(out1));
//wire reset_div5;
//reg [2:0] div5; initial div5 <= 3'd0;
//assign reset_div5 = div5[2] & !div5[1] & !div5[0];
//
//always @ (posedge clk) begin
//	div5 <= (reset_div5) ? 3'd0 : div5 + 1'b1;
//end
//assign out = reset_div5;

endmodule
