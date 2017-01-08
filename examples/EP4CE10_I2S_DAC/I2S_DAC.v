module I2S_DAC(clk50M, sck, ws, sd, 
//DAC_L, DAC_R
dac_dat,
outr,
sw1
);

//general
input wire clk50M;
//i2s
input wire sck, ws, sd;
//custom dac
//output wire DAC_L, DAC_R;

//r2r 8bit dac
output wire [7:0] dac_dat;

output wire outr;

input wire sw1;

//i2s receiver
wire [31:0] data_left;
wire [31:0] data_right;
i2s_receive2 rcv(.sck(sck), 
                 .ws(ws),
					  .sd(sd),
					  .data_left(data_left),
					  .data_right(data_right));
					  
assign outr = (data_left==data_right);				  
					  
wire [31:0] us_data_left = data_left + 32'b10000000000000000000000000000000; //signed data in unsigned register. this is conversion		  
wire [31:0] us_data_right = data_right + 32'b10000000000000000000000000000000; //signed data in unsigned register. this is conversion		  

//assign dac_dat = us_data_right[31:31-7];					  
					  				  

//dac regs cross domain
reg  [31:0] word_l_;
//reg  [31:0] word_r_;					  
reg  [31:0] word_l__;
//reg  [31:0] word_r__;					  
reg [7:0] word_l;
//reg [7:0] word_r;	

wire clk200M;
pll200M pll(.inclk0(clk50M),
	         .c0(clk200M));

always @(posedge clk200M) begin
	word_l_ <= (us_data_left);
	//word_r_ <= (us_data_left);
	word_l__ <= word_l_;
	//word_r__ <= word_r_;
	
	word_l <=  word_l__[31:31-7];
	//word_r <=  word_r__[31:31-7];
end				  
					  
//dacs
wire DAC_L, DAC_R;
ds8dac1 /*#(.width(8))*/ dac_l(.clk(clk200M), 
                            .DACin(word_l), 
			              		 .DACout(DAC_L));					  

//pwm8dac1 dac_r(.clk(clk200M), 
//               .in_data(word_r), 
//					.sout(DAC_R));					  

//standart 8 bit pwm dac
assign dac_dat = (sw1) ? {DAC_L,DAC_L,DAC_L,DAC_L,DAC_L,DAC_L,DAC_L,DAC_L} : word_l;
//assign dac_dat = us_data_right[31:31-7];					  


//hi pwm, lo r2r					
//assign dac_dat = {word_l__[23],word_l__[22],word_l__[21],word_l__[20],word_l__[19],word_l__[18],word_l__[17],word_l__[16]};
					
					
endmodule
