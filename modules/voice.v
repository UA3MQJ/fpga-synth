module voice(clk, gate, note, pitch, detune, mix, wave_form, signal_out, ss1, ss2, ss3, ss4, ss5, ss6, ss7);
input wire clk;
input wire gate;
input wire [6:0] note;
input wire [6:0] detune;
input wire [6:0] mix;
input wire [13:0] pitch;
output wire [7:0] signal_out;
//input wire [31:0] adder;
input wire [2:0] wave_form;
output wire [7:0] ss1, ss2, ss3, ss4, ss5, ss6, ss7;
// wave_forms
parameter SAW      = 3'b000;
parameter SQUARE   = 3'b001; //with PWM
parameter TRIANGLE = 3'b010;
parameter SINE     = 3'b011;
parameter RAMP     = 3'b100;
parameter SAW_TRI  = 3'b101;
parameter SUPERSAW = 3'b110;
parameter NOISE    = 3'b111;

reg [1:0] gate_prev;
initial gate_prev<=2'b00;
always @(posedge clk) gate_prev <= {gate_prev[0], gate};
wire TRIG = (gate_prev==2'b01);

wire [31:0] adder_center;
note_pitch2dds  transl1(clk, note, pitch, adder_center); 

wire [31:0] vco_out;
dds #(.WIDTH(32)) vco(.clk(clk), .adder(adder_center), .signal_out(vco_out));

wire [31:0] vco_out1;
wire [31:0] vco_out2;
wire [31:0] vco_out3;
wire [31:0] vco_out4;
wire [31:0] vco_out5;
wire [31:0] vco_out6;

wire [31:0] adder_vco1 = adder_center - ((adder_center*((16'd07210*detune)>>8))>>16);
wire [31:0] adder_vco2 = adder_center - ((adder_center*((16'd04121*detune)>>8))>>16);
wire [31:0] adder_vco3 = adder_center - ((adder_center*((16'd01279*detune)>>8))>>16);
wire [31:0] adder_vco4 = adder_center + ((adder_center*((16'd01304*detune)>>8))>>16);
wire [31:0] adder_vco5 = adder_center + ((adder_center*((16'd04074*detune)>>8))>>16);
wire [31:0] adder_vco6 = adder_center + ((adder_center*((16'd07042*detune)>>8))>>16);

dds #(.WIDTH(32)) vco1(.clk(clk), .adder(adder_vco1), .signal_out(vco_out1));
dds #(.WIDTH(32)) vco2(.clk(clk), .adder(adder_vco2), .signal_out(vco_out2));
dds #(.WIDTH(32)) vco3(.clk(clk), .adder(adder_vco3), .signal_out(vco_out3));
dds #(.WIDTH(32)) vco4(.clk(clk), .adder(adder_vco4), .signal_out(vco_out4));
dds #(.WIDTH(32)) vco5(.clk(clk), .adder(adder_vco5), .signal_out(vco_out5));
dds #(.WIDTH(32)) vco6(.clk(clk), .adder(adder_vco6), .signal_out(vco_out6));


wire [7:0] saw_out = vco_out[31:31-7];
wire [7:0] square_out = (vco_out[31:31-7] > 127) ? 8'b11111111 : 1'b00000000;
wire [7:0] tri_out = (saw_out>8'd191) ? 7'd127 + ((saw_out << 1) - 9'd511) : 
                     (saw_out>8'd063) ? 8'd255 - ((saw_out << 1) - 7'd127) : 7'd127 + (saw_out << 1);
//SINE table
wire [7:0] sine_out;
sine sine_rom(.address(vco_out[31:31-7]),
				  .q(sine_out),
				  .clock(clk));

wire [7:0] ramp_out = -saw_out;	
wire [7:0] saw_tri_out = (saw_out > 7'd127) ?  -saw_out : 8'd127 + saw_out;	

//supersaw table
wire [7:0] supersaw_out;

reg [10:0] phase1;
reg [10:0] phase2;
reg [10:0] phase3;
reg [10:0] phase4;
reg [10:0] phase5;
reg [10:0] phase6;
reg [10:0] phase7;

initial begin
	phase1 <= 11'd0412;
	phase2 <= 11'd0222;
	phase3 <= 11'd056;
	phase4 <= 11'd1412;
	phase5 <= 11'd2412;
	phase6 <= 11'd0412;
	phase7 <= 11'd22;
end

wire [7:0] rnd_ph_shift1;
wire [7:0] rnd_ph_shift2;
wire [7:0] rnd_ph_shift3;
wire [7:0] rnd_ph_shift4;
wire [7:0] rnd_ph_shift5;
wire [7:0] rnd_ph_shift6;
wire [7:0] rnd_ph_shift7;
rndx #(.WIDTH(8), .INIT_VAL(32'hF1928374)) random8_ss1(.clk(clk), .signal_out(rnd_ph_shift1));
rndx #(.WIDTH(8), .INIT_VAL(32'hF1234567)) random8_ss2(.clk(clk), .signal_out(rnd_ph_shift2));
rndx #(.WIDTH(8), .INIT_VAL(32'hF2345678)) random8_ss3(.clk(clk), .signal_out(rnd_ph_shift3));
rndx #(.WIDTH(8), .INIT_VAL(32'hF3456789)) random8_ss4(.clk(clk), .signal_out(rnd_ph_shift4));
rndx #(.WIDTH(8), .INIT_VAL(32'hF4567891)) random8_ss5(.clk(clk), .signal_out(rnd_ph_shift5));
rndx #(.WIDTH(8), .INIT_VAL(32'hF5678911)) random8_ss6(.clk(clk), .signal_out(rnd_ph_shift6));
rndx #(.WIDTH(8), .INIT_VAL(32'hF6789112)) random8_ss7(.clk(clk), .signal_out(rnd_ph_shift7));



always @(posedge clk) begin
	if (TRIG) begin
		phase1 <= phase1 + rnd_ph_shift1;
		phase2 <= phase2 + rnd_ph_shift2;
		phase3 <= phase3 + rnd_ph_shift3;
		phase4 <= phase4 + rnd_ph_shift4;
		phase5 <= phase5 + rnd_ph_shift5;
		phase6 <= phase6 + rnd_ph_shift6;
		phase7 <= phase7 + rnd_ph_shift7;	
	end
end

wire [10:0] supersaw_rom_addr1 = vco_out1[31:31-10] + phase1;
wire [10:0] supersaw_rom_addr2 = vco_out2[31:31-10] + phase2;
wire [10:0] supersaw_rom_addr3 = vco_out3[31:31-10] + phase3;
wire [10:0] supersaw_rom_addr4 = vco_out[31:31-10] + phase4;
wire [10:0] supersaw_rom_addr5 = vco_out4[31:31-10] + phase5;
wire [10:0] supersaw_rom_addr6 = vco_out5[31:31-10] + phase6;
wire [10:0] supersaw_rom_addr7 = vco_out6[31:31-10] + phase7;

wire [7:0] supersaw_out1;
wire [7:0] supersaw_out2;
wire [7:0] supersaw_out3;
wire [7:0] supersaw_out4;
wire [7:0] supersaw_out5;
wire [7:0] supersaw_out6;
wire [7:0] supersaw_out7;

supersaw supersaw_rom1(.address(supersaw_rom_addr1),
				  .q(supersaw_out1),
				  .clock(clk));
supersaw supersaw_rom2(.address(supersaw_rom_addr2),
				  .q(supersaw_out2),
				  .clock(clk));
supersaw supersaw_rom3(.address(supersaw_rom_addr3),
				  .q(supersaw_out3),
				  .clock(clk));
supersaw supersaw_rom4(.address(supersaw_rom_addr4),
				  .q(supersaw_out4),
				  .clock(clk));
supersaw supersaw_rom5(.address(supersaw_rom_addr5),
				  .q(supersaw_out5),
				  .clock(clk));
supersaw supersaw_rom6(.address(supersaw_rom_addr6),
				  .q(supersaw_out6),
				  .clock(clk));
supersaw supersaw_rom7(.address(supersaw_rom_addr7),
				  .q(supersaw_out7),
				  .clock(clk));
				  
wire [7:0] center_volume = (mix==7'd00) ? 8'd0254 :
(mix==7'd01) ? 8'd0253 :
(mix==7'd02) ? 8'd0252 :
(mix==7'd03) ? 8'd0251 :
(mix==7'd04) ? 8'd0250 :
(mix==7'd05) ? 8'd0249 :
(mix==7'd06) ? 8'd0248 :
(mix==7'd07) ? 8'd0247 :
(mix==7'd08) ? 8'd0246 :
(mix==7'd09) ? 8'd0244 :
(mix==7'd010) ? 8'd0243 :
(mix==7'd011) ? 8'd0242 :
(mix==7'd012) ? 8'd0241 :
(mix==7'd013) ? 8'd0240 :
(mix==7'd014) ? 8'd0239 :
(mix==7'd015) ? 8'd0238 :
(mix==7'd016) ? 8'd0237 :
(mix==7'd017) ? 8'd0236 :
(mix==7'd018) ? 8'd0234 :
(mix==7'd019) ? 8'd0233 :
(mix==7'd020) ? 8'd0232 :
(mix==7'd021) ? 8'd0231 :
(mix==7'd022) ? 8'd0230 :
(mix==7'd023) ? 8'd0229 :
(mix==7'd024) ? 8'd0228 :
(mix==7'd025) ? 8'd0227 :
(mix==7'd026) ? 8'd0226 :
(mix==7'd027) ? 8'd0224 :
(mix==7'd028) ? 8'd0223 :
(mix==7'd029) ? 8'd0222 :
(mix==7'd030) ? 8'd0221 :
(mix==7'd031) ? 8'd0220 :
(mix==7'd032) ? 8'd0219 :
(mix==7'd033) ? 8'd0218 :
(mix==7'd034) ? 8'd0217 :
(mix==7'd035) ? 8'd0216 :
(mix==7'd036) ? 8'd0214 :
(mix==7'd037) ? 8'd0213 :
(mix==7'd038) ? 8'd0212 :
(mix==7'd039) ? 8'd0211 :
(mix==7'd040) ? 8'd0210 :
(mix==7'd041) ? 8'd0209 :
(mix==7'd042) ? 8'd0208 :
(mix==7'd043) ? 8'd0207 :
(mix==7'd044) ? 8'd0206 :
(mix==7'd045) ? 8'd0204 :
(mix==7'd046) ? 8'd0203 :
(mix==7'd047) ? 8'd0202 :
(mix==7'd048) ? 8'd0201 :
(mix==7'd049) ? 8'd0200 :
(mix==7'd050) ? 8'd0199 :
(mix==7'd051) ? 8'd0198 :
(mix==7'd052) ? 8'd0197 :
(mix==7'd053) ? 8'd0196 :
(mix==7'd054) ? 8'd0194 :
(mix==7'd055) ? 8'd0193 :
(mix==7'd056) ? 8'd0192 :
(mix==7'd057) ? 8'd0191 :
(mix==7'd058) ? 8'd0190 :
(mix==7'd059) ? 8'd0189 :
(mix==7'd060) ? 8'd0188 :
(mix==7'd061) ? 8'd0187 :
(mix==7'd062) ? 8'd0186 :
(mix==7'd063) ? 8'd0184 :
(mix==7'd064) ? 8'd0183 :
(mix==7'd065) ? 8'd0182 :
(mix==7'd066) ? 8'd0181 :
(mix==7'd067) ? 8'd0180 :
(mix==7'd068) ? 8'd0179 :
(mix==7'd069) ? 8'd0178 :
(mix==7'd070) ? 8'd0177 :
(mix==7'd071) ? 8'd0176 :
(mix==7'd072) ? 8'd0174 :
(mix==7'd073) ? 8'd0173 :
(mix==7'd074) ? 8'd0172 :
(mix==7'd075) ? 8'd0171 :
(mix==7'd076) ? 8'd0170 :
(mix==7'd077) ? 8'd0169 :
(mix==7'd078) ? 8'd0168 :
(mix==7'd079) ? 8'd0167 :
(mix==7'd080) ? 8'd0166 :
(mix==7'd081) ? 8'd0164 :
(mix==7'd082) ? 8'd0163 :
(mix==7'd083) ? 8'd0162 :
(mix==7'd084) ? 8'd0161 :
(mix==7'd085) ? 8'd0160 :
(mix==7'd086) ? 8'd0159 :
(mix==7'd087) ? 8'd0158 :
(mix==7'd088) ? 8'd0157 :
(mix==7'd089) ? 8'd0156 :
(mix==7'd090) ? 8'd0154 :
(mix==7'd091) ? 8'd0153 :
(mix==7'd092) ? 8'd0152 :
(mix==7'd093) ? 8'd0151 :
(mix==7'd094) ? 8'd0150 :
(mix==7'd095) ? 8'd0149 :
(mix==7'd096) ? 8'd0148 :
(mix==7'd097) ? 8'd0147 :
(mix==7'd098) ? 8'd0146 :
(mix==7'd099) ? 8'd0144 :
(mix==7'd0100) ? 8'd0143 :
(mix==7'd0101) ? 8'd0142 :
(mix==7'd0102) ? 8'd0141 :
(mix==7'd0103) ? 8'd0140 :
(mix==7'd0104) ? 8'd0139 :
(mix==7'd0105) ? 8'd0138 :
(mix==7'd0106) ? 8'd0137 :
(mix==7'd0107) ? 8'd0136 :
(mix==7'd0108) ? 8'd0134 :
(mix==7'd0109) ? 8'd0133 :
(mix==7'd0110) ? 8'd0132 :
(mix==7'd0111) ? 8'd0131 :
(mix==7'd0112) ? 8'd0130 :
(mix==7'd0113) ? 8'd0129 :
(mix==7'd0114) ? 8'd0128 :
(mix==7'd0115) ? 8'd0127 :
(mix==7'd0116) ? 8'd0125 :
(mix==7'd0117) ? 8'd0124 :
(mix==7'd0118) ? 8'd0123 :
(mix==7'd0119) ? 8'd0122 :
(mix==7'd0120) ? 8'd0121 :
(mix==7'd0121) ? 8'd0120 :
(mix==7'd0122) ? 8'd0119 :
(mix==7'd0123) ? 8'd0118 :
(mix==7'd0124) ? 8'd0117 :
(mix==7'd0125) ? 8'd0115 :
(mix==7'd0126) ? 8'd0114 :
(mix==7'd0127) ? 8'd0113 : 8'd0255 ;

wire [7:0] side_volume = (mix==7'd00) ? 8'd011 :
(mix==7'd01) ? 8'd014 :
(mix==7'd02) ? 8'd016 :
(mix==7'd03) ? 8'd019 :
(mix==7'd04) ? 8'd021 :
(mix==7'd05) ? 8'd024 :
(mix==7'd06) ? 8'd026 :
(mix==7'd07) ? 8'd029 :
(mix==7'd08) ? 8'd031 :
(mix==7'd09) ? 8'd034 :
(mix==7'd010) ? 8'd036 :
(mix==7'd011) ? 8'd038 :
(mix==7'd012) ? 8'd041 :
(mix==7'd013) ? 8'd043 :
(mix==7'd014) ? 8'd045 :
(mix==7'd015) ? 8'd047 :
(mix==7'd016) ? 8'd050 :
(mix==7'd017) ? 8'd052 :
(mix==7'd018) ? 8'd054 :
(mix==7'd019) ? 8'd056 :
(mix==7'd020) ? 8'd058 :
(mix==7'd021) ? 8'd060 :
(mix==7'd022) ? 8'd062 :
(mix==7'd023) ? 8'd064 :
(mix==7'd024) ? 8'd066 :
(mix==7'd025) ? 8'd068 :
(mix==7'd026) ? 8'd070 :
(mix==7'd027) ? 8'd072 :
(mix==7'd028) ? 8'd074 :
(mix==7'd029) ? 8'd076 :
(mix==7'd030) ? 8'd078 :
(mix==7'd031) ? 8'd080 :
(mix==7'd032) ? 8'd082 :
(mix==7'd033) ? 8'd084 :
(mix==7'd034) ? 8'd085 :
(mix==7'd035) ? 8'd087 :
(mix==7'd036) ? 8'd089 :
(mix==7'd037) ? 8'd091 :
(mix==7'd038) ? 8'd092 :
(mix==7'd039) ? 8'd094 :
(mix==7'd040) ? 8'd096 :
(mix==7'd041) ? 8'd097 :
(mix==7'd042) ? 8'd099 :
(mix==7'd043) ? 8'd0101 :
(mix==7'd044) ? 8'd0102 :
(mix==7'd045) ? 8'd0104 :
(mix==7'd046) ? 8'd0105 :
(mix==7'd047) ? 8'd0107 :
(mix==7'd048) ? 8'd0108 :
(mix==7'd049) ? 8'd0110 :
(mix==7'd050) ? 8'd0111 :
(mix==7'd051) ? 8'd0112 :
(mix==7'd052) ? 8'd0114 :
(mix==7'd053) ? 8'd0115 :
(mix==7'd054) ? 8'd0117 :
(mix==7'd055) ? 8'd0118 :
(mix==7'd056) ? 8'd0119 :
(mix==7'd057) ? 8'd0120 :
(mix==7'd058) ? 8'd0122 :
(mix==7'd059) ? 8'd0123 :
(mix==7'd060) ? 8'd0124 :
(mix==7'd061) ? 8'd0125 :
(mix==7'd062) ? 8'd0126 :
(mix==7'd063) ? 8'd0127 :
(mix==7'd064) ? 8'd0129 :
(mix==7'd065) ? 8'd0130 :
(mix==7'd066) ? 8'd0131 :
(mix==7'd067) ? 8'd0132 :
(mix==7'd068) ? 8'd0133 :
(mix==7'd069) ? 8'd0134 :
(mix==7'd070) ? 8'd0135 :
(mix==7'd071) ? 8'd0136 :
(mix==7'd072) ? 8'd0136 :
(mix==7'd073) ? 8'd0137 :
(mix==7'd074) ? 8'd0138 :
(mix==7'd075) ? 8'd0139 :
(mix==7'd076) ? 8'd0140 :
(mix==7'd077) ? 8'd0141 :
(mix==7'd078) ? 8'd0141 :
(mix==7'd079) ? 8'd0142 :
(mix==7'd080) ? 8'd0143 :
(mix==7'd081) ? 8'd0144 :
(mix==7'd082) ? 8'd0144 :
(mix==7'd083) ? 8'd0145 :
(mix==7'd084) ? 8'd0146 :
(mix==7'd085) ? 8'd0146 :
(mix==7'd086) ? 8'd0147 :
(mix==7'd087) ? 8'd0147 :
(mix==7'd088) ? 8'd0148 :
(mix==7'd089) ? 8'd0148 :
(mix==7'd090) ? 8'd0149 :
(mix==7'd091) ? 8'd0149 :
(mix==7'd092) ? 8'd0150 :
(mix==7'd093) ? 8'd0150 :
(mix==7'd094) ? 8'd0151 :
(mix==7'd095) ? 8'd0151 :
(mix==7'd096) ? 8'd0151 :
(mix==7'd097) ? 8'd0152 :
(mix==7'd098) ? 8'd0152 :
(mix==7'd099) ? 8'd0152 :
(mix==7'd0100) ? 8'd0153 :
(mix==7'd0101) ? 8'd0153 :
(mix==7'd0102) ? 8'd0153 :
(mix==7'd0103) ? 8'd0153 :
(mix==7'd0104) ? 8'd0153 :
(mix==7'd0105) ? 8'd0153 :
(mix==7'd0106) ? 8'd0154 :
(mix==7'd0107) ? 8'd0154 :
(mix==7'd0108) ? 8'd0154 :
(mix==7'd0109) ? 8'd0154 :
(mix==7'd0110) ? 8'd0154 :
(mix==7'd0111) ? 8'd0154 :
(mix==7'd0112) ? 8'd0154 :
(mix==7'd0113) ? 8'd0154 :
(mix==7'd0114) ? 8'd0154 :
(mix==7'd0115) ? 8'd0154 :
(mix==7'd0116) ? 8'd0153 :
(mix==7'd0117) ? 8'd0153 :
(mix==7'd0118) ? 8'd0153 :
(mix==7'd0119) ? 8'd0153 :
(mix==7'd0120) ? 8'd0153 :
(mix==7'd0121) ? 8'd0153 :
(mix==7'd0122) ? 8'd0152 :
(mix==7'd0123) ? 8'd0152 :
(mix==7'd0124) ? 8'd0152 :
(mix==7'd0125) ? 8'd0151 :
(mix==7'd0126) ? 8'd0151 :
(mix==7'd0127) ? 8'd0151 : 8'd0151;

//wire [15:0] supersaw_out4_mix16 = supersaw_out4 * center_volume;
//wire [7:0] supersaw_out4_mix = supersaw_out4_mix16 >> 8;



//wire [15:0] supersaw_out1_mix16 = supersaw_out1 * side_volume;
//wire [15:0] supersaw_out2_mix16 = supersaw_out2 * side_volume;
//wire [15:0] supersaw_out3_mix16 = supersaw_out3 * side_volume;
//wire [15:0] supersaw_out5_mix16 = supersaw_out5 * side_volume;
//wire [15:0] supersaw_out6_mix16 = supersaw_out6 * side_volume;
//wire [15:0] supersaw_out7_mix16 = supersaw_out7 * side_volume;

//wire [7:0] supersaw_out1_mix = supersaw_out1_mix16 >> 8;
//wire [7:0] supersaw_out2_mix = supersaw_out2_mix16 >> 8;
//wire [7:0] supersaw_out3_mix = supersaw_out3_mix16 >> 8;
//wire [7:0] supersaw_out5_mix = supersaw_out5_mix16 >> 8;
//wire [7:0] supersaw_out6_mix = supersaw_out6_mix16 >> 8;
//wire [7:0] supersaw_out7_mix = supersaw_out7_mix16 >> 8;

wire [7:0] supersaw_out1_mix;
wire [7:0] supersaw_out2_mix;
wire [7:0] supersaw_out3_mix;
wire [7:0] supersaw_out4_mix;
wire [7:0] supersaw_out5_mix;
wire [7:0] supersaw_out6_mix;
wire [7:0] supersaw_out7_mix;

svca #(.WIDTH(8)) digital_vca_t4(.in(supersaw_out4) , .cv(supersaw_out4), .signal_out(supersaw_out4_mix));

svca #(.WIDTH(8)) digital_vca_t1(.in(supersaw_out1) , .cv(side_volume), .signal_out(supersaw_out1_mix));
svca #(.WIDTH(8)) digital_vca_t2(.in(supersaw_out2) , .cv(side_volume), .signal_out(supersaw_out2_mix));
svca #(.WIDTH(8)) digital_vca_t3(.in(supersaw_out3) , .cv(side_volume), .signal_out(supersaw_out3_mix));
svca #(.WIDTH(8)) digital_vca_t5(.in(supersaw_out5) , .cv(side_volume), .signal_out(supersaw_out5_mix));
svca #(.WIDTH(8)) digital_vca_t6(.in(supersaw_out6) , .cv(side_volume), .signal_out(supersaw_out6_mix));
svca #(.WIDTH(8)) digital_vca_t7(.in(supersaw_out7) , .cv(side_volume), .signal_out(supersaw_out7_mix));

				  
assign ss1 = supersaw_out1_mix;
assign ss2 = supersaw_out2_mix;
assign ss3 = supersaw_out3_mix;
assign ss4 = supersaw_out4_mix;
assign ss5 = supersaw_out5_mix;
assign ss6 = supersaw_out6_mix;
assign ss7 = supersaw_out7_mix;

//noise
reg  [7:0] noise_reg;
wire [7:0] noise_out = noise_reg;
wire [7:0] noise_sig;
//16000 hz GENERATOR
wire clk16000;
frq1divmod1 divider1(clk, 25'd1563, clk16000); //50000000 / 16000 / 2 = 1563
reg [1:0] clk16000_prev=2'b00;
always @(posedge clk) clk16000_prev <= {clk16000_prev[0], clk16000};
wire clk16000_posege = (clk16000_prev==2'b01);
rndx #(.WIDTH(8)) random8(.clk(clk), .signal_out(noise_sig));
always @(posedge clk) begin
	if (clk16000_posege) begin
		noise_reg <= noise_sig;
	end
end


//signal_out
assign signal_out = (wave_form ==      SAW) ? saw_out :
                    (wave_form ==   SQUARE) ? square_out : 
                    (wave_form == TRIANGLE) ? tri_out : 
                    (wave_form ==     SINE) ? sine_out : 
                    (wave_form ==     RAMP) ? ramp_out : 
                    (wave_form ==  SAW_TRI) ? saw_tri_out : 
                    (wave_form == SUPERSAW) ? supersaw_out : 
                    (wave_form ==    NOISE) ? noise_out : 8'd127;

endmodule
