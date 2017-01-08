module note_pitch2dds_2st_gen(CLK, NOTE, PITCH, ADDER);

input wire CLK;
input wire [6:0] NOTE;
input wire [13:0] PITCH;
output reg [31:0] ADDER;

reg [32:0] ADDER_sum;
reg [31:0] ADDER_n;
reg [7:0]  ADDER_mul;

reg [3:0] state;
reg [6:0] NOTE_local;
reg [13:0] PITCH_local;

initial begin
	NOTE_local <= 7'd0;
	PITCH_local <= 14'd08192; // 0 - pitch wheel
	ADDER <= 32'd0;
	state <= 4'd0;
	SNOTE <= 9'D0;
end

//считаем Pitch Wheel
// in_val сначала << 7
// а потом
//; ALGORITHM:
//; Clear accumulator
//; Add input / 1024 to accumulator >> 10
//; Add input / 2048 to accumulator >> 11
//; Move accumulator to result
//; Approximated constant: 0.00146484, Error: 0 %

//вычитаем 8192 
wire signed [14:0] in_val_centered = (PITCH - 14'd08192);

//15+11 = 26 бит
wire signed [26:0] in_val_fix = in_val_centered <<< 11;

//mul 0.00146484
wire signed [26:0] in_val_mul = (in_val_fix >>> 10) + (in_val_fix >>> 11);

//старшая часть, которую прибавим к номеру ноты
wire signed [26:0] t_in_val_hi = in_val_mul >>> 11;
wire signed [7:0] in_val_hi = t_in_val_hi[7:0];

//младшая 8 битная часть, которую будем применять в линейной интерполяции
wire [7:0] in_val_lo = in_val_mul[10:3];

reg signed [8:0] SNOTE ; //= NOTE;

wire [7:0] NOTE_n = ((SNOTE + in_val_hi)<   0) ?    7'd0 : 
				        ((SNOTE + in_val_hi)> 127) ? 7'd0127 : SNOTE + in_val_hi;
                    
//wire [7:0] NOTE_2 = ((SNOTE + in_val_hi + 1)<   0) ?   7'd0 : 
//					     ((SNOTE + in_val_hi + 1)> 127) ? 7'd127 : NOTE + in_val_hi + 1'b1;

always @ (posedge CLK) begin
		case(NOTE_n)
			7'd000: ADDER_n <= 32'd0702;
			7'd001: ADDER_n <= 32'd0702;
			7'd002: ADDER_n <= 32'd0702;
			7'd003: ADDER_n <= 32'd0702;
			7'd004: ADDER_n <= 32'd0702;
			7'd005: ADDER_n <= 32'd0702;
			7'd006: ADDER_n <= 32'd0702;
			7'd007: ADDER_n <= 32'd0702;
			7'd008: ADDER_n <= 32'd0702;
			7'd009: ADDER_n <= 32'd0702;
			7'd010: ADDER_n <= 32'd0702;
			7'd011: ADDER_n <= 32'd0702;
			7'd012: ADDER_n <= 32'd0702;
			7'd013: ADDER_n <= 32'd0744;
			7'd014: ADDER_n <= 32'd0788;
			7'd015: ADDER_n <= 32'd0835;
			7'd016: ADDER_n <= 32'd0885;
			7'd017: ADDER_n <= 32'd0937;
			7'd018: ADDER_n <= 32'd0993;
			7'd019: ADDER_n <= 32'd01052;
			7'd020: ADDER_n <= 32'd01115;
			7'd021: ADDER_n <= 32'd01181;
			7'd022: ADDER_n <= 32'd01251;
			7'd023: ADDER_n <= 32'd01326;
			7'd024: ADDER_n <= 32'd01405;
			7'd025: ADDER_n <= 32'd01488;
			7'd026: ADDER_n <= 32'd01577;
			7'd027: ADDER_n <= 32'd01670;
			7'd028: ADDER_n <= 32'd01770;
			7'd029: ADDER_n <= 32'd01875;
			7'd030: ADDER_n <= 32'd01986;
			7'd031: ADDER_n <= 32'd02105;
			7'd032: ADDER_n <= 32'd02230;
			7'd033: ADDER_n <= 32'd02362;
			7'd034: ADDER_n <= 32'd02503;
			7'd035: ADDER_n <= 32'd02652;
			7'd036: ADDER_n <= 32'd02809;
			7'd037: ADDER_n <= 32'd02976;
			7'd038: ADDER_n <= 32'd03153;
			7'd039: ADDER_n <= 32'd03341;
			7'd040: ADDER_n <= 32'd03539;
			7'd041: ADDER_n <= 32'd03750;
			7'd042: ADDER_n <= 32'd03973;
			7'd043: ADDER_n <= 32'd04209;
			7'd044: ADDER_n <= 32'd04459;
			7'd045: ADDER_n <= 32'd04724;
			7'd046: ADDER_n <= 32'd05005;
			7'd047: ADDER_n <= 32'd05303;
			7'd048: ADDER_n <= 32'd05618;
			7'd049: ADDER_n <= 32'd05952;
			7'd050: ADDER_n <= 32'd06306;
			7'd051: ADDER_n <= 32'd06681;
			7'd052: ADDER_n <= 32'd07079;
			7'd053: ADDER_n <= 32'd07500;
			7'd054: ADDER_n <= 32'd07946;
			7'd055: ADDER_n <= 32'd08418;
			7'd056: ADDER_n <= 32'd08919;
			7'd057: ADDER_n <= 32'd09449;
			7'd058: ADDER_n <= 32'd010011;
			7'd059: ADDER_n <= 32'd010606;
			7'd060: ADDER_n <= 32'd011237;
			7'd061: ADDER_n <= 32'd011905;
			7'd062: ADDER_n <= 32'd012613;
			7'd063: ADDER_n <= 32'd013363;
			7'd064: ADDER_n <= 32'd014157;
			7'd065: ADDER_n <= 32'd014999;
			7'd066: ADDER_n <= 32'd015891;
			7'd067: ADDER_n <= 32'd016836;
			7'd068: ADDER_n <= 32'd017837;
			7'd069: ADDER_n <= 32'd018898;
			7'd070: ADDER_n <= 32'd020022;
			7'd071: ADDER_n <= 32'd021212;
			7'd072: ADDER_n <= 32'd022473;
			7'd073: ADDER_n <= 32'd023810;
			7'd074: ADDER_n <= 32'd025226;
			7'd075: ADDER_n <= 32'd026726;
			7'd076: ADDER_n <= 32'd028315;
			7'd077: ADDER_n <= 32'd029998;
			7'd078: ADDER_n <= 32'd031782;
			7'd079: ADDER_n <= 32'd033672;
			7'd080: ADDER_n <= 32'd035674;
			7'd081: ADDER_n <= 32'd037796;
			7'd082: ADDER_n <= 32'd040043;
			7'd083: ADDER_n <= 32'd042424;
			7'd084: ADDER_n <= 32'd044947;
			7'd085: ADDER_n <= 32'd047620;
			7'd086: ADDER_n <= 32'd050451;
			7'd087: ADDER_n <= 32'd053451;
			7'd088: ADDER_n <= 32'd056630;
			7'd089: ADDER_n <= 32'd059997;
			7'd090: ADDER_n <= 32'd063565;
			7'd091: ADDER_n <= 32'd067344;
			7'd092: ADDER_n <= 32'd071349;
			7'd093: ADDER_n <= 32'd075591;
			7'd094: ADDER_n <= 32'd080086;
			7'd095: ADDER_n <= 32'd084849;
			7'd096: ADDER_n <= 32'd089894;
			7'd097: ADDER_n <= 32'd095239;
			7'd098: ADDER_n <= 32'd0100902;
			7'd099: ADDER_n <= 32'd0106902;
			7'd0100: ADDER_n <= 32'd0113259;
			7'd0101: ADDER_n <= 32'd0119994;
			7'd0102: ADDER_n <= 32'd0127129;
			7'd0103: ADDER_n <= 32'd0134689;
			7'd0104: ADDER_n <= 32'd0142698;
			7'd0105: ADDER_n <= 32'd0151183;
			7'd0106: ADDER_n <= 32'd0160173;
			7'd0107: ADDER_n <= 32'd0169697;
			7'd0108: ADDER_n <= 32'd0179788;
			7'd0109: ADDER_n <= 32'd0190478;
			7'd0110: ADDER_n <= 32'd0201805;
			7'd0111: ADDER_n <= 32'd0213805;
			7'd0112: ADDER_n <= 32'd0226518;
			7'd0113: ADDER_n <= 32'd0239988;
			7'd0114: ADDER_n <= 32'd0254258;
			7'd0115: ADDER_n <= 32'd0269377;
			7'd0116: ADDER_n <= 32'd0285395;
			7'd0117: ADDER_n <= 32'd0302366;
			7'd0118: ADDER_n <= 32'd0320345;
			7'd0119: ADDER_n <= 32'd0339394;
			7'd0120: ADDER_n <= 32'd0359575;
			7'd0121: ADDER_n <= 32'd0380957;
			7'd0122: ADDER_n <= 32'd0403610;
			7'd0123: ADDER_n <= 32'd0427610;
			7'd0124: ADDER_n <= 32'd0453037;
			7'd0125: ADDER_n <= 32'd0479976;
			7'd0126: ADDER_n <= 32'd0508516;
			7'd0127: ADDER_n <= 32'd0538754;
		endcase
	
	if (state==4'd00) begin
		SNOTE <= NOTE;
		if ((NOTE!=NOTE_local)||(PITCH!=PITCH_local)) begin
			NOTE_local<=NOTE;
			PITCH_local<=PITCH;
			ADDER_sum<=33'd0;
			ADDER_n<=32'd0;
			ADDER_mul<=8'd0;
		end
	end else if ((state==4'd01)||(state==4'd02)||(state==4'd03)) begin
		SNOTE <= SNOTE + 1'b1; //if не обязателен
		
		if (state==4'd01) ADDER_mul <= 8'd0255 - in_val_lo;
		if (state==4'd02) ADDER_mul <=           in_val_lo;
		
		ADDER_sum <= ADDER_sum + (ADDER_mul * ADDER_n);
				
	end else if (state==4'd04) begin
		ADDER <= ADDER_sum >> 8;
	end
end
	
always @ (posedge CLK) begin
	//смена стейтов
	if (state==4'd00) begin
		if ((NOTE!=NOTE_local)||(PITCH!=PITCH_local)) begin
			state<=4'd01;
		end else begin
			state<=4'd00;
		end
	end else if (state==4'd01) begin
		state<=4'd02;
	end else if (state==4'd02) begin
		state<=4'd03;
	end else if (state==4'd03) begin
		state<=4'd04;
	end else if (state==4'd04) begin
		state<=4'd00;
	end
end
						 
endmodule
