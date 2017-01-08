/*module spi_rcv(CLK, SCK, MOSI, MISO, SSEL, LED);

input wire CLK, SCK, SSEL, MOSI;
output wire MISO, LED;


wire [7:0] MSG;
spi_slave spi1(.CLK(CLK),
               .SCK(SCK), 
			      .MOSI(MOSI), 
			      .MISO(MISO), 
			      .SSEL(SSEL),
				   .MSG(MSG));
				
assign LED = (MSG==8'b11111111);*/

module spi_rcv(clk, 
	      led_gnd1, led_gnd2,  //LED grounds
	      led6, led7, led8, led9, led10, led12, led13, led15, led16, led17, led18, led19, led20, led21,
              led_second_tick
             );
input wire clk;
output wire led_gnd1, led_gnd2;
output wire led6, led7, led8, led9, led10, led12, led13, led15, led16, led17, led18, led19, led20, led21;
output wire led_second_tick;

//clk - general clock 32768
reg [14:0] clk_div; initial clk_div <= 15'd0; //?? may be not implement
always @(posedge clk) clk_div <= clk_div + 1'b1;
wire divided_clk = clk_div[4];
reg  divided_clk_prev;
always @(posedge clk) divided_clk_prev <= divided_clk;
wire divided_clk_posedge = ((divided_clk_prev==1'b0)&&(divided_clk==1'b1));

wire res;
pu_reset res_gen(.clk(clk), .res(res));

reg [3:0] gnd_sel;

always @(posedge clk) begin
  if (res) begin
    gnd_sel <= 4'b0001;
  end else begin
    if (divided_clk_posedge) gnd_sel <= {gnd_sel[2],gnd_sel[1],gnd_sel[0],gnd_sel[3]};
  end
end

assign led_gnd1 =  gnd_sel[0];
assign led_gnd2 =  gnd_sel[2];

/*
wire [3:0] m = 0;
wire [3:0] mm;
wire [3:0] h;
wire [3:0] hh;

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
*/
//hide hour zero
//wire h_show = !(hh==0);

assign led6 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&(b1&&h_show)) || (led_gnd2&&(b1&&h_show));  //  b1
assign led7 =  (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&(a1&&h_show)) || (led_gnd2&&(g1&&h_show)); // a1/g1
assign led8 =  (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&(d1&&h_show)) || (led_gnd2&&(e1&&h_show)); // d1/e1

assign led9  = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&e2) || (led_gnd2&&(c1&&h_show)); // e2/c1 
assign led10 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&g2) || (led_gnd2&&b2); // g2/b2
assign led12 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&d2) || (led_gnd2&&c2); // d2/c2
assign led13 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&f2) || (led_gnd2&&a2); // f2/a2

assign led15 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&a3) || (led_gnd2&&f3); // a3/f3 
assign led16 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&b3) || (led_gnd2&&g3); // b3/g3
assign led17 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&c3) || (led_gnd2&&d3); // c3/d3

assign led18 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&e4) || ((led_gnd2)&&e3); // e3/e4 !!
assign led19 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&g4) || ((led_gnd2)&&b4); // g4/b4
assign led20 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&d4) || ((led_gnd2)&&c4); // d4/c4
assign led21 = (led_gnd1 || led_gnd2) ? 1 : 0;//(led_gnd1&&f4) || ((led_gnd2)&&a4); // f4/a4


//one second tick indicator
//assign led_second_tick = led_gnd1 && clk_div[14];
assign led_second_tick = 1;

endmodule

module pu_reset(clk, res);
input wire clk;
output wire res;

reg [3:0] res_cntr;
assign res = (res_cntr!=4'b1111);
wire [3:0] next_res_cntr = (res) ? res_cntr : res_cntr + 1'b1; 

always @(posedge clk) res_cntr <= next_res_cntr;

endmodule
