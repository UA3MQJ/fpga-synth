module test01(clk, 
	      led_gnd1, led_gnd2,  //LED grounds
	      led6, led7, led8, led9, led10, led12, led13, led15, led16, led17, led18, led19, led20, led21,
              led_second_tick
             );
input wire clk;
output wire led_gnd1, led_gnd2;
output wire led6, led7, led8, led9, led10, led12, led13, led15, led16, led17, led18, led19, led20, led21, led_second_tick;

//clk - general clock 32768
reg [14:0] clk_div; initial clk_div <= 15'd0; //?? may be not implement
always @(posedge clk) clk_div <= clk_div + 1'b1;
wire divided_clk = clk_div[3];
reg  divided_clk_prev;
always @(posedge clk) divided_clk_prev <= divided_clk;
wire divided_clk_posedge = ((divided_clk_prev==1'b0)&&(divided_clk==1'b1));

assign led_gnd1 =  clk_div[0];
assign led_gnd2 = ~clk_div[0];

wire [3:0] m;
wire [3:0] mm;
wire [3:0] h;
wire [3:0] hh;


wire m_en  = divided_clk_posedge;
wire mm_en;
wire h_en;
wire hh_en;

wire m_cy;
wire mm_cy;
wire h_cy;
wire hh_cy;

cntr #(.max(9)) cnt_m(  .en(divided_clk_posedge),  .clk(clk), .out(m),  .cy(m_cy) );
cntr #(.max(5)) cnt_mm( .en(m_cy),                 .clk(clk), .out(mm), .cy(mm_cy) );
cntr #(.max(9)) cnt_h(  .en(mm_cy),                .clk(clk), .out(h),  .cy(h_cy),  .res((hh==2)&&(h==4)) );
cntr #(.max(2)) cnt_hh( .en(h_cy),                 .clk(clk), .out(hh), .cy(hh_cy), .res((hh==2)&&(h==4)) );

wire [6:0] s_m;
wire [6:0] s_mm;
wire [6:0] s_h;
wire [6:0] s_hh;

bcd2seg sseg_m( .sin(m),  .sout(s_m));
bcd2seg sseg_mm(.sin(mm), .sout(s_mm));
bcd2seg sseg_h( .sin(h),  .sout(s_h));
bcd2seg sseg_hh(.sin(hh), .sout(s_hh));

wire a1,b1,c1,d1,e1,f1,g1;
wire a2,b2,c2,d2,e2,f2,g2;
wire a3,b3,c3,d3,e3,f3,g3;
wire a4,b4,c4,d4,e4,f4,g4;

assign {g4, f4, e4, d4, c4, b4, a4} = s_m; 
assign {g3, f3, e3, d3, c3, b3, a3} = s_mm; 
assign {g2, f2, e2, d2, c2, b2, a2} = s_h; 
assign {g1, f1, e1, d1, c1, b1, a1} = s_hh; 

//hide hour zero
wire h_show = !(hh==0);

assign led6 = (led_gnd1) ? (b1&&h_show):(b1&&h_show);  //  b1
assign led7 = (led_gnd1) ? (a1&&h_show):(g1&&h_show); // a1/g1
assign led8 = (led_gnd1) ? (d1&&h_show):(e1&&h_show); // d1/e1

assign led9  = (led_gnd1) ? e2:(c1&&h_show); // e2/c1 
assign led10 = (led_gnd1) ? g2:b2; // g2/b2
assign led12 = (led_gnd1) ? d2:c2; // d2/c2
assign led13 = (led_gnd1) ? f2:a2; // f2/a2

assign led15 = (led_gnd1) ? a3:f3; // a3/f3 
assign led16 = (led_gnd1) ? b3:g3; // b3/g3
assign led17 = (led_gnd1) ? c3:d3; // c3/d3

assign led18 = (led_gnd1) ? e4:e3; // e3/e4 !!
assign led19 = (led_gnd1) ? g4:b4; // g4/b4
assign led20 = (led_gnd1) ? d4:c4; // d4/c4
assign led21 = (led_gnd1) ? f4:a4; // f4/a4

//one second tick indicator
assign led_second_tick = led_gnd1 && clk_div[14];

endmodule

