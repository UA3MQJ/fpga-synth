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

wire keys;
assign keys = key0 & key1 & sw0 & sw1 & sw2 & sw3;

//PLL
//midi_in midiin(clk50PLL, ~locked, MIDI_IN, NOTE_OFF, NOTE_ON, PRESSURE, CONTROL, PROGRAM, CHPRESSURE, PICH, CHAN, NOTE, VELOCITY, LSB, MSB);
midi_in midiin(clk50PLL, ~locked, MIDI_IN, CH_MESSAGE, CHAN, NOTE, VELOCITY, LSB, MSB);

//без PLL
//midi_in midiin(clk50M, 1'b0, MIDI_IN, NOTE_OFF, NOTE_ON, PRESSURE, CONTROL, PROGRAM, CHPRESSURE, PICH, CHAN, NOTE, VELOCITY, LSB, MSB);

wire NOTE_ON  = (CH_MESSAGE==4'b1001); //признак появления сообщения note on
wire NOTE_OFF = (CH_MESSAGE==4'b1000); //признак появления сообщения note off

wire GATE; // сигнал GATE в единице между note on и note off
reg_rs GATEreg(.clk(clk50PLL), .s(NOTE_ON), .r(NOTE_OFF), .data_out(GATE));

wire [6:0] LAST_NOTE; //последняя полученная нота
reg7 NOTEreg(.clk(clk50PLL), .wr(NOTE_ON), .data(NOTE), .data_out(LAST_NOTE));

//PITCH 
wire ptch_strobe = (CH_MESSAGE==4'b1110); //сообщение PITCH
wire [13:0] pitch_val; // значение PITCH
reg14w pitch_reg(.clk(clk50PLL), .wr(ptch_strobe), .data({MSB,LSB}), .data_out(pitch_val));

wire [31:0] adder1;
note_pitch2dds  transl1(clk50PLL, LAST_NOTE, pitch_val, adder1); 

wire [31:0] vco1out;
//dds32 vco1(clk50PLL, adder1, vco1out);
dds #(.WIDTH(32)) vco1(.clk(clk50PLL), .adder(adder1), .signal_out(vco1out));

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

//Q
wire [6:0] Q1;
wire Q1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd048))||rst; // control change & 48 control - LSB
wire [6:0] Q1_value =  (rst) ? 7'b0111111 : MSB;
reg7 Q1reg(clk50PLL, Q1_lsb, Q1_value, Q1);

//noise
wire [6:0] N1;
wire N1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd049))||rst; // control change & 49 control - LSB
wire [6:0] N1_value =  (rst) ? 7'd01 : MSB;
reg7 N1reg(clk50PLL, N1_lsb, N1_value, N1);



wire [7:0] square_out = (vco1out[31:31-7] > 127) ? 8'b11111111 : 1'b00000000;
wire [7:0] saw_out    = vco1out[31:31-7];
wire [7:0] t_wave_form  = (sw0) ? saw_out : square_out;
wire [7:0] wave_form  = (sw3) ? ((t_wave_form >> 1) + 6'd63) : 8'd127;

//digi VCA
wire [7:0] vco_with_digital_vca;
svca #(.WIDTH(8)) digital_vca_1(.clk(clk50M), .in(wave_form) , .cv(adsr1out[31:31-7]), .signal_out(vco_with_digital_vca));

//ext VCO
wire out1bit;
//rnd8dac1 dac1_vco(clk50PLL, wave_form, out1bit);
//ds8dac1 dac1_vco(clk50PLL, wave_form, out1bit);
//ds8dac1 dac1_vco(clk50PLL, (sw1) ? wave_form : vco_with_digital_vca, out1bit);
pwm8dac1 dac1_vco(clk50PLL, (sw1) ? wave_form : vco_with_digital_vca, out1bit);


wire [31:0] adsr1out;
adsr32 adsr1(clk50PLL, GATE, A1, D1, {S1,25'b0}, R1, adsr1out);


//wire pwm1out_d;
//pwm8dac1 dac1(clk50PLL, vcaout1, pwm1out_d);


wire pwm1vca_out;
wire [7:0] adsr8 = adsr1out[31:31-7];
vca_pwm8dac1 dac1_vca(clk50PLL, adsr8, pwm1vca_out);
assign pwm_out_0 = (sw1) ? ~pwm1vca_out : 0 ; //vca всесгда открыт (тут получилось с инверсией)
//assign pwm_out_0 = pwm_q_out;

wire pwm_q_out;
pwm8dac1 dac2(clk50PLL, {Q1,1'b0}, pwm_q_out);
assign pwm_out_1 = ~pwm_q_out;



//SNAR
wire clk44100;
frq1divmod1 divider1(clk50PLL, 566, clk44100); //50000000 / 44100 = 1134
reg [1:0] clk44100_pre=2'b00;
always @(posedge clk50PLL) clk44100_pre <= {clk44100_pre[0], clk44100};
wire clk44100_posege = (clk44100_pre==2'b01);


reg [12:0] ram_snare_addr;
initial ram_snare_addr <= 14'd0;
wire [7:0] ram_snare_data;

always @(posedge clk50PLL) begin
	if (clk44100_posege) begin
		if (ram_snare_addr==8190) begin
			ram_snare_addr <= 13'd0;
		end else begin
			ram_snare_addr <= ram_snare_addr + 1'b1;
		end
		
	end
end

snar snare_rom(.address(ram_snare_addr),
					 .q(ram_snare_data),
					 .clock(clk44100_posege));

wire out_noise1bit;
ds8dac1 dac1_noise(clk50PLL, ram_snare_data, out_noise1bit); // sync (!)
//SNAR


assign snd_0 = out1bit;
assign snd_1 = (sw2) ? out_noise1bit : 1'b0;
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
