module i2s_dco #(parameter DATA_WIDTH = 16
				) (clk, adder, note_on, sdata, lrclk, mck, sck);

input wire clk; //general clock of project (top level) 50 MHz
input wire [31:0] adder; //adder for dds
input wire note_on;
output reg sdata; initial sdata <= 1'b0;

//output reg mck; initial mck <= 1'b0; 
output wire mck, sck, lrclk;
reg [9:0]  mck_div; initial mck_div<=10'd0;
/* тактуем счетчик от 50 мгц
 бит - частота
 0 - 25.000.000
 1 - 12.500.000
 2 -  6.250.000
 3 -  3.125.000
 4 -  1.562.500
 5 -    781.250
 6 -    390.625
 7 -    195.312.5
 8 -     97.656.25
 9 -     48.828.125

*/


parameter LR_BIT = 7; // 9 for 48 khz; 7 for 195 khz
parameter SCK_BIT = LR_BIT - 6; // lr*64
parameter MCK_BIT = 0;


assign mck   = mck_div[MCK_BIT];
assign lrclk = mck_div[LR_BIT];
assign sck   = mck_div[SCK_BIT];

reg lrclk_prev; initial lrclk_prev <= 1'b1;
wire lrclk_change = ~(lrclk_prev == lrclk);
reg [DATA_WIDTH-1:0] ch_data; initial ch_data <= {DATA_WIDTH{1'b0}};
reg sck_prev; initial sck_prev <= 1'b0;
wire sck_neg = (sck_prev==1'b1 && sck==1'b0);

reg [31:0] DDS_acc; initial DDS_acc <= 32'd0;
wire [31:0] sgnd_data = DDS_acc - 32'b10000000000000000000000000000000;//saw
//wire [31:0] sgnd_data = (DDS_acc[31]) ? 32'h00000000 - 32'b10000000000000000000000000000000 : 32'hffffffff - 32'b10000000000000000000000000000000;

always @(posedge clk) begin
	mck_div <= mck_div + 1'b1;
	lrclk_prev <= lrclk;
	sck_prev <= sck;
	
	if (sck_neg) begin
		if (lrclk_change) begin
			//ch_data <= (lrclk) ? left_chan : right_chan;
			ch_data <= (note_on) ? sgnd_data : 32'h80000000 - 32'b10000000000000000000000000000000;
			DDS_acc <= DDS_acc + adder;
		end else begin
			ch_data <= ch_data << 1;
		end
		sdata <= ch_data[DATA_WIDTH-1];
	end
	
	
end

endmodule
