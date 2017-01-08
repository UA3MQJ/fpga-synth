module ModuleTester(clk, out);

// Port Declaration


input   clk;
output [127:0] out;
/*
reg [127:0] cnt; initial cnt<=128'd0;
always @(posedge clk) cnt<=cnt+ 1'b1;

assign out=cnt; */


dec_cnt dc(.clock(clk),
           .sclr(0),
			  .q(out));


endmodule
