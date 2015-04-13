`timescale 1ns / 100ps
module VitaPolyOne(
			input wire clk50M,
			input wire key0,
			input wire key1,
			input wire sw0,
			input wire sw1,
			input wire sw2,
			input wire sw3,
			output snd_0,
			output snd_1,
			output snd_2,
			output snd_3,
			output snd_4,
			output snd_5,
			output snd_6,
			output snd_7,
			output pwm_out_0,
			output pwm_out_1,
			input wire MIDI_IN,
			output led0,
			output led1,
			output [7:0] SEG
);

//генератор 50 МГц
wire clk50PLL;
wire locked;
nco clk50M_PLL(clk50M, clk50PLL, locked);

wire [3:0] CH_MESSAGE;
wire [3:0] CHAN;
wire [6:0] NOTE;
wire [6:0] VELOCITY;
wire [6:0] LSB;
wire [6:0] MSB;

wire keys;
assign keys = key0 & key1 & sw0 & sw1 & sw2 & sw3;

//PLL
//midi_in midiin(clk50PLL, ~locked, MIDI_IN, NOTE_OFF, NOTE_ON, PRESSURE, CONTROL, PROGRAM, CHPRESSURE, PICH, CHAN, NOTE, VELOCITY, LSB, MSB);
midi_in midiin(clk50PLL, ~locked, MIDI_IN, CH_MESSAGE, CHAN, NOTE, VELOCITY, LSB, MSB);

//без PLL
//midi_in midiin(clk50M, 1'b0, MIDI_IN, NOTE_OFF, NOTE_ON, PRESSURE, CONTROL, PROGRAM, CHPRESSURE, PICH, CHAN, NOTE, VELOCITY, LSB, MSB);

wire NOTE_ON  = (CH_MESSAGE==4'b1001);
wire NOTE_OFF = (CH_MESSAGE==4'b1000);

wire GATE;
reg_rs GATEreg(clk50PLL, NOTE_ON, NOTE_OFF, GATE);


wire [6:0] LAST_NOTE;
reg7 NOTEreg(clk50PLL, NOTE_ON, NOTE, LAST_NOTE);

wire [31:0] adder1;
//note2dds transl1(clk50PLL, LAST_NOTE, adder1);

//PITCH 

wire ptch_strobe = (CH_MESSAGE==4'b1110);
wire [13:0] pitch_val;
reg14w pitch_reg(clk50PLL, ptch_strobe, {MSB,LSB}, pitch_val);

note_pitch2dds  transl1(clk50PLL, LAST_NOTE, pitch_val, adder1); 

wire [31:0] vco1out;
dds32 vco1(clk50PLL, adder1, vco1out);

//масштабирование
wire [31:0] add_value;
lin2exp_t exp(MSB, add_value);

//A1
wire [13:0] A1;
wire A1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd016)); // control change & 16 control - LSB
reg14w A1reg(clk50PLL, A1_lsb, add_value[13:0], A1);

//D1
wire [13:0] D1;
wire D1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd017)); // control change & 17 control - LSB
reg14w D1reg(clk50PLL, D1_lsb, add_value[13:0], D1);

//S1
wire [6:0] S1;
wire S1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd018)); // control change & 18 control - LSB
reg7 S1reg(clk50PLL, S1_lsb, MSB, S1);

//R1
wire [13:0] R1;
wire R1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd019)); // control change & 19 control - LSB
reg14w R1reg(clk50PLL, R1_lsb, add_value[13:0], R1);

wire [31:0] adsr1out;
adsr32 adsr1(clk50PLL, GATE, A1, D1, {S1,25'b0}, R1, adsr1out);

//digi VCA
wire [7:0] vcaout1;
vca8 vca_1(clk50M, vco1out[31:31-7], adsr1out[31:31-7], vcaout1);

wire pwm1out_d;
pwm8dac1 dac1(clk50PLL, vcaout1, pwm1out_d);

//ext VCO
wire pwm1out;
//rnd8dac1 dac1_vco(clk50PLL, vco1out[31:31-7], pwm1out);
//ds8dac1 dac1_vco(clk50PLL, vco1out[31:31-7], pwm1out);
pwm8dac1 dac1_vco(clk50PLL, vco1out[31:31-7], pwm1out);

wire pwm1vca_out;
pwm8dac1 dac1_vca(clk50PLL, adsr1out[31:31-7], pwm1vca_out);

//assign pwm_out_1 = (sw0==0) ?  pwm1vca_out : 1;
//assign pwm_out_0 = (sw0==0) ? ~pwm1vca_out : 0;
pwm8dac1 dac_test0(clk50PLL, 8'd127, pwm_out_0);


initial begin
	SEG_buf <= 7'd0;
end

assign snd_0 = pwm1out;
assign snd_1 = 0;
assign snd_2 = 1'b0;
assign snd_3 = 1'b0;
assign snd_4 = 1'b0;
assign snd_5 = 1'b0;
assign snd_6 = 1'b0;
assign snd_7 = 1'b0;

assign led0 = GATE;
assign led1 = ~MIDI_IN;

assign SEG = (GATE) ? {1'b0,SEG_buf} : 8'd0;
//assign SEG = {~MIDI_IN,SEG_buf};


reg [6:0] SEG_buf;


//вывод номера канала ноты
//always @ (CHAN) begin
//	case(CHAN)
//вывод номера ноты
always @ (LAST_NOTE[3:0]) begin
	case(LAST_NOTE[3:0])
//вывод velocity
//always @ (tVELOCITY[3:0]) begin
//	case(tVELOCITY[3:0])
//вывод контроллера
//always @ (tMSB[3:0]) begin
//	case(tMSB[3:0])
	
      4'h0: SEG_buf <= 7'b0111111;
      4'h1: SEG_buf <= 7'b0000110;
      4'h2: SEG_buf <= 7'b1011011;
      4'h3: SEG_buf <= 7'b1001111;
      4'h4: SEG_buf <= 7'b1100110;
      4'h5: SEG_buf <= 7'b1101101;
      4'h6: SEG_buf <= 7'b1111101;
      4'h7: SEG_buf <= 7'b0000111;
      4'h8: SEG_buf <= 7'b1111111;
      4'h9: SEG_buf <= 7'b1101111;
      4'hA: SEG_buf <= 7'b1110111;
      4'hB: SEG_buf <= 7'b1111100;
      4'hC: SEG_buf <= 7'b0111001;
      4'hD: SEG_buf <= 7'b1011110;
      4'hE: SEG_buf <= 7'b1111001;
      4'hF: SEG_buf <= 7'b1110001;
      default: SEG_buf <= 7'b0111111;
   endcase
end

endmodule