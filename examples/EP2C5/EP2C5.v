module EP2C5(clk50M, key0, led0, led1, led2, MIDI_IN, 
				//VCA
				a1, a2, a3, a4, ac1, ac2, ac3, ac4
);
//ports
input wire clk50M, key0, MIDI_IN;
output wire led0, led1, led2;

//генератор сброса
wire rst;
powerup_reset res_gen(.clk(clk50M), .key(~key0), .rst(rst));

//Organ outputs
//audio out's
output wire a1, a2, a3, a4;
//control out's
output wire ac1,ac2,ac3,ac4;


//synth

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

reg note_on_reg;
initial note_on_reg <= 0;

/*
always @(posedge clk50M) begin
	if (NOTE_ON) begin
		note_on_reg <= 1;
	end else if (NOTE_OFF) begin
		note_on_reg <= 0;
	end
end */

assign led0 = MIDI_IN;
assign led1 = ~note_on_reg;
assign led2 = 1'b1;



//523,31 герц А1
//50.000.000 / 523,31 = 95545,661271521660201410253960368
//frqdivmod #(.DIV(95546)) divider2(.clk(clk50M), .s_out(a1));

//12 клоков 2х частоты верхней октавы.
wire clk1, clk2, clk3, clk4, clk5, clk6, clk7, clk8, clk9, clk10, clk11, clk12;
frqdivmod #(.DIV(6327)) divider1(.clk(clk50M), .s_out(clk12));
frqdivmod #(.DIV(6704)) divider2(.clk(clk50M), .s_out(clk11));
frqdivmod #(.DIV(7102)) divider3(.clk(clk50M), .s_out(clk10));
frqdivmod #(.DIV(7525)) divider4(.clk(clk50M), .s_out(clk9));
frqdivmod #(.DIV(7972)) divider5(.clk(clk50M), .s_out(clk8));
frqdivmod #(.DIV(8446)) divider6(.clk(clk50M), .s_out(clk7));
frqdivmod #(.DIV(8948)) divider7(.clk(clk50M), .s_out(clk6));
frqdivmod #(.DIV(9480)) divider8(.clk(clk50M), .s_out(clk5));
frqdivmod #(.DIV(10044)) divider9(.clk(clk50M), .s_out(clk4));
frqdivmod #(.DIV(10641)) divider10(.clk(clk50M), .s_out(clk3));
frqdivmod #(.DIV(11274)) divider11(.clk(clk50M), .s_out(clk2));
frqdivmod #(.DIV(11945)) divider12(.clk(clk50M), .s_out(clk1));

assign clkout = clk50M;


//теперь буду тактовать счетчики по 11 бит каждый. каждый бит - след. октава вниз
reg [10:0] rg01;
reg [10:0] rg02;
reg [10:0] rg03;
reg [10:0] rg04;
reg [10:0] rg05;
reg [10:0] rg06;
reg [10:0] rg07;
reg [10:0] rg08;
reg [10:0] rg09;
reg [10:0] rg10;
reg [10:0] rg11;
reg [10:0] rg12;

initial rg01 <= 11'd0;
initial rg02 <= 11'd0;
initial rg03 <= 11'd0;
initial rg04 <= 11'd0;
initial rg05 <= 11'd0;
initial rg06 <= 11'd0;
initial rg07 <= 11'd0;
initial rg08 <= 11'd0;
initial rg09 <= 11'd0;
initial rg10 <= 11'd0;
initial rg11 <= 11'd0;
initial rg12 <= 11'd0;

reg trg01;
reg trg02;
reg trg03;
reg trg04;
reg trg05;
reg trg06;
reg trg07;
reg trg08;
reg trg09;
reg trg10;
reg trg11;
reg trg12;
initial trg01<=0;
initial trg02<=0;
initial trg03<=0;
initial trg04<=0;
initial trg05<=0;
initial trg06<=0;
initial trg07<=0;
initial trg08<=0;
initial trg09<=0;
initial trg10<=0;
initial trg11<=0;
initial trg12<=0;

always @ (posedge clk50M) begin
	trg01 <= clk1;
	if (clk1!=trg01) rg01 <= rg01 + 1'b1;
end

always @ (posedge clk50M) begin
	trg02 <= clk2;
	if (clk2!=trg02) rg02 <= rg02 + 1'b1;
end

always @ (posedge clk50M) begin
	trg03 <= clk3;
	if (clk3!=trg03) rg03 <= rg03 + 1'b1;
end

always @ (posedge clk50M) begin
	trg04 <= clk4;
	if (clk4!=trg04) rg04 <= rg04 + 1'b1;
end

always @ (posedge clk50M) begin
	trg05 <= clk5;
	if (clk5!=trg05) rg05 <= rg05 + 1'b1;
end

always @ (posedge clk50M) begin
	trg06 <= clk6;
	if (clk6!=trg06) rg06 <= rg06 + 1'b1;
end

always @ (posedge clk50M) begin
	trg07 <= clk7;
	if (clk7!=trg07) rg07 <= rg07 + 1'b1;
end

always @ (posedge clk50M) begin
	trg08 <= clk8;
	if (clk8!=trg08) rg08 <= rg08 + 1'b1;
end

always @ (posedge clk50M) begin
	trg09 <= clk9;
	if (clk9!=trg09) rg09 <= rg09 + 1'b1;
end

always @ (posedge clk50M) begin
	trg10 <= clk10;
	if (clk10!=trg10) rg10 <= rg10 + 1'b1;
end

always @ (posedge clk50M) begin
	trg11 <= clk11;
	if (clk11!=trg11) rg11 <= rg11 + 1'b1;
end

always @ (posedge clk50M) begin
	trg12 <= clk12;
	if (clk12!=trg12) rg12 <= rg12 + 1'b1;
end


//теперь надо сделать wire на 127 линий
wire [127:0] line16; //регистр 16! в понятиях органов!

genvar i;
generate 
	for(i = 0; i < 10; i = i + 1 ) begin : i_gen
		assign line16[127 - (12*i) ] = rg12[i];
		assign line16[126 - (12*i) ] = rg11[i];
		assign line16[125 - (12*i) ] = rg10[i];
		assign line16[124 - (12*i) ] = rg09[i];
		assign line16[123 - (12*i) ] = rg08[i];
		assign line16[122 - (12*i) ] = rg07[i];
		assign line16[121 - (12*i) ] = rg06[i];
		assign line16[120 - (12*i) ] = rg05[i];
		assign line16[119 - (12*i) ] = rg04[i];
		assign line16[118 - (12*i) ] = rg03[i];
		assign line16[117 - (12*i) ] = rg02[i];
		assign line16[116 - (12*i) ] = rg01[i];
	end
endgenerate 

//теперь надо сделать wire на 127 линий
wire [127:0] line8; //регистр 8! в понятиях органов!
generate 
	for(i = 0; i < 9; i = i + 1 ) begin : i8_gen
		assign line8[127 - (12*(i+1)) ] = rg12[i];
		assign line8[126 - (12*(i+1)) ] = rg11[i];
		assign line8[125 - (12*(i+1)) ] = rg10[i];
		assign line8[124 - (12*(i+1)) ] = rg09[i];
		assign line8[123 - (12*(i+1)) ] = rg08[i];
		assign line8[122 - (12*(i+1)) ] = rg07[i];
		assign line8[121 - (12*(i+1)) ] = rg06[i];
		assign line8[120 - (12*(i+1)) ] = rg05[i];
		assign line8[119 - (12*(i+1)) ] = rg04[i];
		assign line8[118 - (12*(i+1)) ] = rg03[i];
		assign line8[117 - (12*(i+1)) ] = rg02[i];
		assign line8[116 - (12*(i+1)) ] = rg01[i];
	end
endgenerate 

//теперь надо сделать wire на 127 линий
wire [127:0] line4; //регистр 4! в понятиях органов!
generate 
	for(i = 0; i < 8; i = i + 1 ) begin : i4_gen
		assign line4[127 - (12*(i+2)) ] = rg12[i];
		assign line4[126 - (12*(i+2)) ] = rg11[i];
		assign line4[125 - (12*(i+2)) ] = rg10[i];
		assign line4[124 - (12*(i+2)) ] = rg09[i];
		assign line4[123 - (12*(i+2)) ] = rg08[i];
		assign line4[122 - (12*(i+2)) ] = rg07[i];
		assign line4[121 - (12*(i+2)) ] = rg06[i];
		assign line4[120 - (12*(i+2)) ] = rg05[i];
		assign line4[119 - (12*(i+2)) ] = rg04[i];
		assign line4[118 - (12*(i+2)) ] = rg03[i];
		assign line4[117 - (12*(i+2)) ] = rg02[i];
		assign line4[116 - (12*(i+2)) ] = rg01[i];
	end
endgenerate 

//теперь надо сделать wire на 127 линий
wire [127:0] line2; //регистр 2! в понятиях органов!
generate 
	for(i = 0; i < 7; i = i + 1 ) begin : i2_gen
		assign line2[127 - (12*(i+3)) ] = rg12[i];
		assign line2[126 - (12*(i+3)) ] = rg11[i];
		assign line2[125 - (12*(i+3)) ] = rg10[i];
		assign line2[124 - (12*(i+3)) ] = rg09[i];
		assign line2[123 - (12*(i+3)) ] = rg08[i];
		assign line2[122 - (12*(i+3)) ] = rg07[i];
		assign line2[121 - (12*(i+3)) ] = rg06[i];
		assign line2[120 - (12*(i+3)) ] = rg05[i];
		assign line2[119 - (12*(i+3)) ] = rg04[i];
		assign line2[118 - (12*(i+3)) ] = rg03[i];
		assign line2[117 - (12*(i+3)) ] = rg02[i];
		assign line2[116 - (12*(i+3)) ] = rg01[i];
	end
endgenerate 


reg [127:0] keys; //регистр нажатых клавиш.
//будет использоваться, как маска


//теперь 127 линий пропускаем через маску
wire [127:0] line16_out; //регистр 16! в понятиях органов!
wire [127:0] line8_out; //регистр 8! в понятиях органов!
wire [127:0] line4_out; //регистр 4! в понятиях органов!
wire [127:0] line2_out; //регистр 4! в понятиях органов!

generate 
	for(i = 0; i < 128; i = i + 1 ) begin : ii_gen
		assign line16_out[i] = line16[i] && keys[i];
		assign line8_out[i]  = line8[i]  && keys[i];
		assign line4_out[i]  = line4[i]  && keys[i];
		assign line2_out[i]  = line2[i]  && keys[i];
	end
endgenerate

//суммируем все линии в один выход (чума)
reg [7:0] line16_out_sum;
reg [7:0] line8_out_sum;
reg [7:0] line4_out_sum;
reg [7:0] line2_out_sum;
integer j;
always @(line16_out) begin
	line16_out_sum = 8'd0;
	for(j = 0; j < 128; j = j + 1 ) begin : j_gen
		line16_out_sum = line16_out_sum + line16_out[j];
	end
end
always @(line8_out) begin
	line8_out_sum = 8'd0;
	for(j = 0; j < 128; j = j + 1 ) begin : j1_gen
		line8_out_sum = line8_out_sum + line8_out[j];
	end
end
always @(line4_out) begin
	line4_out_sum = 8'd0;
	for(j = 0; j < 128; j = j + 1 ) begin : j2_gen
		line4_out_sum = line4_out_sum + line4_out[j];
	end
end
always @(line2_out) begin
	line2_out_sum = 8'd0;
	for(j = 0; j < 128; j = j + 1 ) begin : j3_gen
		line2_out_sum = line2_out_sum + line2_out[j];
	end
end


//4 ШИМ сигнала  С1, С2, С3, С4
//общий для всех счетчик
reg [6:0] pwm_run;
initial pwm_run <= 7'd0;
always @(posedge clk50M) pwm_run <= pwm_run + 1'b1;

//счетчик для 8 битного ШИМ
reg [7:0] pwm2_run;
initial pwm2_run <= 8'd0;
always @(posedge clk50M) pwm2_run <= pwm2_run + 1'b1;

wire [7:0] result16;
wire [7:0] result8;
wire [7:0] result4;
wire [7:0] result2;

svca dca1(.in(line16_out_sum << 4), .cv({C1, 1'b0}), .signal_out(result16));
svca dca2(.in(line8_out_sum << 4), .cv({C2, 1'b0}), .signal_out(result8));
svca dca3(.in(line4_out_sum << 4), .cv({C3, 1'b0}), .signal_out(result4));
svca dca4(.in(line2_out_sum << 4), .cv({C4, 1'b0}), .signal_out(result2));



assign a1 = pwm2_run < result16;
assign a2 = pwm2_run < result8;
assign a3 = pwm2_run < result4;
assign a4 = pwm2_run < result2;

//данные возьму с контроллов, которые были назначены на ADSR, ибо мне лень.
//вот это надо как-то изящно упростить!
wire [6:0] C1;
wire C1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd055))||rst; // control change & 55 control - LSB
wire [6:0] C1_value =  (rst) ? 7'd00 : MSB;
reg7 C1_reg(clk50M, C1_lsb, C1_value, C1);

wire [6:0] C2;
wire C2_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd056))||rst; // control change & 56 control - LSB
wire [6:0] C2_value =  (rst) ? 7'd00 : MSB;
reg7 C2_reg(clk50M, C2_lsb, C2_value, C2);

wire [6:0] C3;
wire C3_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd057))||rst; // control change & 57 control - LSB
wire [6:0] C3_value =  (rst) ? 7'd00 : MSB;
reg7 C3_reg(clk50M, C3_lsb, C3_value, C3);

wire [6:0] C4;
wire C4_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd058))||rst; // control change & 58 control - LSB
wire [6:0] C4_value =  (rst) ? 7'd00 : MSB;
reg7 C4_reg(clk50M, C4_lsb, C4_value, C4);

assign ac1 = (C1==7'd0) ? 1'b0 : pwm_run < C1;
assign ac2 = (C2==7'd0) ? 1'b0 : pwm_run < C2;
assign ac3 = (C3==7'd0) ? 1'b0 : pwm_run < C3;
assign ac4 = (C4==7'd0) ? 1'b0 : pwm_run < C4;


always @(posedge clk50M) begin
	if (rst) begin
		note_on_reg <= 1'b0;
		keys <= 128'd0;
	end else if (NOTE_ON) begin
		note_on_reg <= 1'b1;
		keys[NOTE] <= 1'b1;
	end else if (NOTE_OFF) begin
		note_on_reg <= 1'b0;
		keys[NOTE] <= 1'b0;
	end
end

endmodule

