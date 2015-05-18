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

wire rst;
powerup_reset res_gen(.clk(clk50PLL), .key(~key0), .rst(rst));

wire [3:0] CH_MESSAGE;
wire [3:0] CHAN;
wire [6:0] NOTE;
wire [6:0] VELOCITY;
wire [6:0] LSB;
wire [6:0] MSB;


//PLL
//midi_in midiin(clk50PLL, ~locked, MIDI_IN, NOTE_OFF, NOTE_ON, PRESSURE, CONTROL, PROGRAM, CHPRESSURE, PICH, CHAN, NOTE, VELOCITY, LSB, MSB);
midi_in midiin(clk50PLL, ~locked, MIDI_IN, CH_MESSAGE, CHAN, NOTE, VELOCITY, LSB, MSB);

//без PLL
//midi_in midiin(clk50M, 1'b0, MIDI_IN, NOTE_OFF, NOTE_ON, PRESSURE, CONTROL, PROGRAM, CHPRESSURE, PICH, CHAN, NOTE, VELOCITY, LSB, MSB);

wire NOTE_ON  = ((CH_MESSAGE==4'b1001)&&(CHAN!=4'd9)); //признак появления сообщения note on
wire NOTE_OFF = ((CH_MESSAGE==4'b1000)&&(CHAN!=4'd9)); //признак появления сообщения note off

wire GATE; // сигнал GATE в единице между note on и note off
reg_rs GATEreg(.clk(clk50PLL), .s(NOTE_ON), .r(NOTE_OFF), .data_out(GATE));

//DRUM CHANEL
wire DRUM_ON  = ((CH_MESSAGE==4'b1001)&&(CHAN==4'd9)); //признак появления сообщения note on
wire DRUM_OFF = ((CH_MESSAGE==4'b1000)&&(CHAN==4'd9)); //признак появления сообщения note off

wire BASS_DRUM_ON  = (DRUM_ON) &&(NOTE==7'd035);
wire BASS_DRUM_OFF = (DRUM_OFF)&&(NOTE==7'd035);
wire BASS_DRUM_GATE; // сигнал GATE в единице между note on и note off
reg_rs BASS_DRUM_GATE_reg(.clk(clk50PLL), .s(BASS_DRUM_ON), .r(BASS_DRUM_OFF), .data_out(BASS_DRUM_GATE));

wire SNAR_DRUM_ON  = (DRUM_ON) &&(NOTE==7'd038);
wire SNAR_DRUM_OFF = (DRUM_OFF)&&(NOTE==7'd038);
wire SNAR_DRUM_GATE; // сигнал GATE в единице между note on и note off
reg_rs SNAR_DRUM_GATE_reg(.clk(clk50PLL), .s(SNAR_DRUM_ON), .r(SNAR_DRUM_OFF), .data_out(SNAR_DRUM_GATE));
//DRUM CHANEL

wire [6:0] LAST_NOTE; //последняя полученная нота
reg7 NOTEreg(.clk(clk50PLL), .wr(NOTE_ON), .data(NOTE), .data_out(LAST_NOTE));

//PITCH 
wire ptch_strobe = (CH_MESSAGE==4'b1110); //сообщение PITCH
wire [13:0] pitch_val; // значение PITCH
reg14w pitch_reg(.clk(clk50PLL), .wr(ptch_strobe), .data({MSB,LSB}), .data_out(pitch_val));

wire [31:0] adder1;
note_pitch2dds  transl1(clk50PLL, LAST_NOTE, pitch_val, adder1); 

//масштабирование 
wire [31:0] add_value;
lin2exp_t exp(.data_in(MSB), .data_out(add_value));

//ADSR
//A1
wire [13:0] A1;
wire A1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd016))||rst; // control change & 16 control - LSB
wire [13:0] A1_value = (rst) ? 14'd07540 : add_value[13:0];
reg14w A1reg(clk50PLL, A1_lsb, A1_value, A1);

//D1
wire [13:0] D1;
wire D1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd017))||rst; // control change & 17 control - LSB
wire [13:0] D1_value =  (rst) ? 14'd07540 : add_value[13:0];
reg14w D1reg(clk50PLL, D1_lsb, D1_value, D1);

//S1
wire [6:0] S1;
wire S1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd018))||rst; // control change & 18 control - LSB
wire [6:0] S1_value =  (rst) ? 7'b1111111 : MSB;
reg7 S1reg(clk50PLL, S1_lsb, S1_value, S1);

//R1
wire [13:0] R1;
wire R1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd019))||rst; // control change & 19 control - LSB
wire [13:0] R1_value =  (rst) ? 14'd07540 : add_value[13:0];
reg14w R1reg(clk50PLL, R1_lsb, R1_value, R1);

//WAVE FORM
wire [6:0] W_FORM;
wire W_FORM_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd048))||rst; // control change & 48 control - LSB
wire [6:0] W_FORM_value =  (rst) ? 7'd0 : MSB;
reg7 W_FORM_reg(clk50PLL, W_FORM_lsb, W_FORM_value, W_FORM);


//ONE VOICE
wire [7:0] voice1_wave_form;
voice voice1(.clk(clk50PLL),
			    .adder(adder1),
				 .wave_form(W_FORM[2:0]),
				 .signal_out(voice1_wave_form));

//ADSR
wire [31:0] adsr1out;
adsr32 adsr1(clk50PLL, GATE, A1, D1, {S1,25'b0}, R1, adsr1out);

//digi VCA
wire [7:0] voice1_with_digital_vca;
svca #(.WIDTH(8)) digital_vca_1(.clk(clk50M), .in(voice1_wave_form) , .cv(adsr1out[31:31-7]), .signal_out(voice1_with_digital_vca));

//analog VCA -> вывод управляющего сигнала на вывод pwm_out_0
wire pwm1vca_out;
wire [7:0] adsr8 = adsr1out[31:31-7];
vca_pwm8dac1 dac1_vca(clk50PLL, adsr8, pwm1vca_out);
assign pwm_out_0 = (sw3) ? ~pwm1vca_out : 1'b0 ; //vca всесгда открыт (тут получилось с инверсией)

//вывод сигнала VCO (либо на всю шкалу, либо масштабированным в цифровом виде)
wire out1bit;
pwm8dac1 ds8dac1(clk50PLL, (sw3) ? voice1_wave_form : voice1_with_digital_vca, out1bit); //pwm8dac1, ds8dac1, rnd8dac1

//Q для управления фильтром -> вывод управляющего сигнала на вывод pwm_out_1
//Q
//wire [6:0] Q1;
//wire Q1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd048))||rst; // control change & 48 control - LSB
//wire [6:0] Q1_value =  (rst) ? 7'b0111111 : MSB;
//reg7 Q1reg(clk50PLL, Q1_lsb, Q1_value, Q1);
//wire pwm_q_out;
//pwm8dac1 dac2(clk50PLL, {Q1,1'b0}, pwm_q_out);
//assign pwm_out_1 = ~pwm_q_out;


//аналоговые выводы
assign snd_0 = out1bit;
assign snd_1 = out1bit;
assign snd_2 = 1'b0;
assign snd_3 = 1'b0;
assign snd_4 = 1'b0;
assign snd_5 = 1'b0;
assign snd_6 = 1'b0;
assign snd_7 = 1'b0;

assign led0 = GATE;
assign led1 = ~MIDI_IN;

assign SEG = (GATE) ? {1'b0,SEG_buf} : 8'd0;

reg [6:0] SEG_buf;

initial begin
	SEG_buf <= 7'd0;
end


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
