`timescale 1ns / 100ps
module VitaPolySimple(
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

//генератор сброса
wire rst;
powerup_reset res_gen(.clk(clk50M), .key(~key0), .rst(rst));

//MIDI вход
wire [3:0] CH_MESSAGE;
wire [3:0] CHAN;
wire [6:0] NOTE;
wire [6:0] LSB;
wire [6:0] MSB;


midi_in midi_in_0(.clk(clk50M), 
					   .rst(rst), 
						.midi_in(MIDI_IN),
						.chan(CHAN),
						.ch_message(CH_MESSAGE),
						.lsb(LSB),
						.msb(MSB),
						.note(NOTE));
						
//ловим ноту на любом, кроме 10-го барабанного канала						
wire NOTE_ON  = ((CH_MESSAGE==4'b1001)&&(CHAN!=4'd9)); //строб признак появления сообщения note on
wire NOTE_OFF = ((CH_MESSAGE==4'b1000)&&(CHAN!=4'd9)); //строб признак появления сообщения note off

wire GATE; // сигнал GATE в единице между note on и note off
//reg_rs GATEreg(.clk(clk50M), .s(NOTE_ON), .r(NOTE_OFF), .data_out(GATE));
					
wire [6:0] LAST_NOTE; //последняя полученная нота
//reg7 NOTEreg(.clk(clk50M), .wr(NOTE_ON), .data(NOTE), .data_out(LAST_NOTE));


note_mono note_mono_0(.clk(clk50M),
							 .rst(rst),
							 .note_on(NOTE_ON), 
							 .note_off(NOTE_OFF), 
							 .note(NOTE),
							 .out_note(LAST_NOTE), 
							 .out_gate(GATE));
							 


//PITCH 
wire ptch_strobe = (CH_MESSAGE==4'b1110)||rst; //сообщение PITCH
wire [13:0] pitch_value = (rst) ? 14'd08192 : {MSB,LSB};
wire [13:0] pitch; // значение PITCH
reg14w pitch_reg(.clk(clk50M), .wr(ptch_strobe), .data(pitch_value), .data_out(pitch));

/* wire [31:0] adder_val;
note_pitch2dds  transl1(.clk(clk50M), 
                        .note(LAST_NOTE), 
								.pitch(pitch_val), 
								.adder(adder_val)); */
/*
note2dds  transl1(.clk(clk50M), 
                  .note(LAST_NOTE), 
						.adder(adder_val));*/

			
//масштабирование 
wire [31:0] add_value;
lin2exp_t exp(.data_in(MSB), .data_out(add_value));
			
//ADSR
//A1
wire [13:0] A1;
wire A1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd016))||rst; // control change & 16 control - LSB
wire [13:0] A1_value = (rst) ? 14'd07540 : add_value[13:0];
reg14w A1reg(clk50M, A1_lsb, A1_value, A1);

//D1
wire [13:0] D1;
wire D1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd017))||rst; // control change & 17 control - LSB
wire [13:0] D1_value =  (rst) ? 14'd07540 : add_value[13:0];
reg14w D1reg(clk50M, D1_lsb, D1_value, D1);

//S1
wire [6:0] S1;
wire S1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd018))||rst; // control change & 18 control - LSB
wire [6:0] S1_value =  (rst) ? 7'b1111111 : MSB;
reg7 S1reg(clk50M, S1_lsb, S1_value, S1);

//R1
wire [13:0] R1;
wire R1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd019))||rst; // control change & 19 control - LSB
wire [13:0] R1_value =  (rst) ? 14'd07540 : add_value[13:0];
reg14w R1reg(clk50M, R1_lsb, R1_value, R1);

//WAVE FORM
wire [6:0] W_FORM;
wire W_FORM_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd048))||rst; // control change & 48 control - LSB
wire [6:0] W_FORM_value =  (rst) ? 7'd0 : MSB;
reg7 W_FORM_reg(clk50M, W_FORM_lsb, W_FORM_value, W_FORM);

// LFO FORM
wire [6:0] LFO_FORM;
wire LFO_FORM_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd049))||rst; // control change & 49 control - LSB
wire [6:0] LFO_FORM_lsb_value =  (rst) ? 7'd0 : MSB;
reg7 LFO_FORM_lsb_reg(clk50M, LFO_FORM_lsb, LFO_FORM_lsb_value, LFO_FORM);

// LFO RATE
wire [6:0] LFO_RATE;
wire LFO_RATE_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd050))||rst; // control change & 50 control - LSB
wire [6:0] LFO_RATE_value =  (rst) ? 7'd0 : MSB;
reg7 LFO_RATE_reg(clk50M, LFO_RATE_lsb, LFO_RATE_value, LFO_RATE);
						
// LFO DEPTH
wire [6:0] LFO_DEPTH;
wire LFO_DEPTH_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd051))||rst; // control change & 51 control - LSB
wire [6:0] LFO_DEPTH_value =  (rst) ? 7'd0 : MSB;
reg7 LFO_DEPTH_reg(clk50M, LFO_DEPTH_lsb, LFO_DEPTH_value, LFO_DEPTH);

// LFO DEPTH2
wire [6:0] LFO_DEPTH2;
wire LFO_DEPTH2_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd052))||rst; // control change & 52 control - LSB
wire [6:0] LFO_DEPTH2_value =  (rst) ? 7'd0 : MSB;
reg7 LFO_DEPTH2_reg(clk50M, LFO_DEPTH2_lsb, LFO_DEPTH2_value, LFO_DEPTH2);

// LFO DEPTH3 (fine)
wire [6:0] LFO_DEPTH3;
wire LFO_DEPTH3_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd053))||rst; // control change & 53 control - LSB
wire [6:0] LFO_DEPTH3_value =  (rst) ? 7'd0 : MSB;
reg7 LFO_DEPTH3_reg(clk50M, LFO_DEPTH3_lsb, LFO_DEPTH3_value, LFO_DEPTH3);

// VREF
wire [6:0] VREF;
wire VREF_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd054))||rst; // control change & 54 control - LSB
wire [6:0] VREF_value =  (rst) ? 7'd024 : MSB;
reg7 VREF_reg(clk50M, VREF_lsb, VREF_value, VREF);
//вывод VREF
ds8dac1 dac_vref(.clk(clk50M), .in_data({VREF, 1'b0}), .sout(pwm_out_0)); //pwm8dac1, ds8dac1, rnd8dac1		



wire [31:0] lfo1_out;
wire [31:0] lfo1_adder = LFO_RATE << 4;

dds #(.WIDTH(32)) lfo_osc1(.clk(clk50M), .adder(lfo1_adder), .signal_out(lfo1_out));

//SINE table
wire [7:0] lfo_sine_out;
sine sine_rom(.address(lfo1_out[31:31-7]),
				  .q(lfo_sine_out),
				  .clock(clk50M));
				  
// wave_forms
parameter SAW      = 3'b000;
parameter SQUARE   = 3'b001; //with PWM
parameter TRIANGLE = 3'b010;
parameter SINE     = 3'b011;
parameter RAMP     = 3'b100;
parameter SAW_TRI  = 3'b101;
parameter NOISE    = 3'b110;
parameter UNDEF    = 3'b111;

wire [7:0] saw_out = lfo1_out[31:31-7];
wire [7:0] square_out = (lfo1_out[31:31-7] > 127) ? 8'b11111111 : 1'b00000000;
wire [7:0] tri_out = (saw_out>8'd191) ? 7'd127 + ((saw_out << 1) - 9'd511) : 
                     (saw_out>8'd063) ? 8'd255 - ((saw_out << 1) - 7'd127) : 7'd127 + (saw_out << 1);
wire [7:0] ramp_out = -saw_out;	
wire [7:0] saw_tri_out = (saw_out > 7'd127) ?  -saw_out : 8'd127 + saw_out;	

				  

//signal_out
wire [7:0] lfo_signal_out = (LFO_FORM ==  SAW) ? saw_out :
                    (LFO_FORM ==   SQUARE) ? square_out : 
                    (LFO_FORM == TRIANGLE) ? tri_out : 
                    (LFO_FORM ==     SINE) ? lfo_sine_out : 
                    (LFO_FORM ==     RAMP) ? ramp_out : 
                    (LFO_FORM ==  SAW_TRI) ? saw_tri_out : 8'd127;
				  
wire [15:0] lfo_with_depth = lfo_signal_out * (LFO_DEPTH << 1);

wire [7:0] lfo_result = lfo_with_depth[15:8];				

//ONE VOICE
wire [7:0] voice1_wave_form;
wire [7:0] ss1,ss2,ss3,ss4,ss5,ss6,ss7;
voice voice1(.clk(clk50M),
			    .gate(GATE),
				 .note(LAST_NOTE),
				 .pitch(pitch),
				 .lfo_sig(lfo_signal_out),
				 .lfo_depth(LFO_DEPTH2),
				 .lfo_depth_fine(LFO_DEPTH3),
				 .wave_form(W_FORM[2:0]),
				 .signal_out(voice1_wave_form));
			
//ADSR
wire [31:0] adsr1out;
adsr32 adsr1(clk50M, GATE, A1, D1, {S1,25'b0}, R1, adsr1out);

wire [7:0] adsr1_8bit = adsr1out[31:31-7];
wire [7:0] lfo_8bit = 8'd255 - lfo_result;
	
//digi VCA lfo
wire [7:0] voice1_with_digital_lfo;
svca #(.WIDTH(8)) digital_vca_1(.in(voice1_wave_form) , .cv(lfo_8bit), .signal_out(voice1_with_digital_lfo));

//digi VCA adsr
wire [7:0] voice1_with_digital_vca;
svca #(.WIDTH(8)) digital_vca_2(.in(voice1_with_digital_lfo) , .cv(adsr1_8bit), .signal_out(voice1_with_digital_vca));

				
assign led0 = ~MIDI_IN;
assign led1 = GATE;
assign SEG  = (GATE) ? {MIDI_IN, S1} : 8'd0;		

//вывод сигнала VCO масштабированным в цифровом виде
wire out1bit;
pwm8dac1 dac1(clk50M, voice1_with_digital_vca, out1bit); //pwm8dac1, ds8dac1, rnd8dac1			


assign snd_0 = out1bit;
assign snd_1 = out1bit;

assign pwm_out_1 = out1bit;


endmodule
