module i2s_tx #(parameter DATA_WIDTH = 16
				) (clk, left_chan, right_chan, sdata, lrclk, mck, sck);

input wire clk; //general clock of project (top level) 50 MHz

input wire [DATA_WIDTH-1:0] left_chan;
input wire [DATA_WIDTH-1:0] right_chan;
output reg sdata; initial sdata <= 1'b0;

//output reg mck; initial mck <= 1'b0; 
output wire mck, sck, lrclk;
reg [9:0]  mck_div; initial mck_div<=10'd0;
//output reg sck; initial sck <= 1'b0; 
//output reg lrclk; initial lrclk <= 1'b0;

parameter LR_BIT = 9; // 9 for 48 khz
parameter SCK_BIT = LR_BIT - 6; // lr*64
parameter MCK_BIT = 1;


assign mck   = ~mck_div[MCK_BIT];
assign lrclk = mck_div[LR_BIT];
assign sck   = mck_div[SCK_BIT];

reg lrclk_prev; initial lrclk_prev <= 1'b1;
wire lrclk_change = ~(lrclk_prev == lrclk);
reg [DATA_WIDTH-1:0] ch_data; initial ch_data <= {DATA_WIDTH{1'b0}};
reg sck_prev; initial sck_prev <= 1'b0;
wire sck_neg = (sck_prev==1'b1 && sck==1'b0);

always @(posedge clk) begin
	mck_div <= mck_div + 1'b1;
	lrclk_prev <= lrclk;
	sck_prev <= sck;
	
	if (sck_neg) begin
		if (lrclk_change) begin
			ch_data <= (lrclk) ? left_chan : right_chan;
		end else begin
			ch_data <= ch_data << 1;
		end
		sdata <= ch_data[DATA_WIDTH-1];
	end
	
	
end

/*
reg [6:0] cnt; initial cnt <= 0;

parameter WIDTH = $clog2(DATA_WIDTH+1);
reg [WIDTH-1:0]      bit_cnt; initial bit_cnt <= {WIDTH{1'b0}};

wire [WIDTH-1:0] next_bit_cnt = (bit_cnt == (DATA_WIDTH-1)) ? {WIDTH{1'b0}} : bit_cnt + 1'b1;

reg [DATA_WIDTH-1:0] ch_data; initial ch_data <= {DATA_WIDTH{1'b0}};

//assign sdata = ch_data[DATA_WIDTH-1];

always @(posedge clk) begin
	mck_div <= mck_div + 1'b1;
	mck <= (mck_div[0]==1'b0) ? ~mck : mck;

	cnt <= cnt + 1'b1;
	sck     <= (cnt[2:0]==3'b000) ? ~sck : sck;
	bit_cnt <= (sck==1 && cnt==0) ? next_bit_cnt : bit_cnt;
	lrclk   <= (sck==1 && cnt==0 && bit_cnt==0) ? ~lrclk : lrclk;
	
	if(sck==1 && cnt==0) begin
		sdata <= ch_data[DATA_WIDTH-1];
		if(bit_cnt==0) begin
			ch_data <= (lrclk) ? left_chan : right_chan;
		end else begin
			ch_data <= ch_data<<1;
		end
	end
end
*/


endmodule
