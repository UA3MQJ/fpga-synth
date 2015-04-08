module note_pitch2dds(CLK, NOTE, PITCH, ADDER);

input wire CLK;
input wire [6:0] NOTE;
input wire [13:0] PITCH;
output reg [31:0] ADDER;

reg [32:0] ADDER_sum;
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

wire [31:0] ADDER_by_table;
note2dds note2dds_table(CLK, NOTE_n[6:0], ADDER_by_table);
						
always @ (posedge CLK) begin
	
	if (state==4'd00) begin
		SNOTE <= NOTE;
		if ((NOTE!=NOTE_local)||(PITCH!=PITCH_local)) begin
			NOTE_local<=NOTE;
			PITCH_local<=PITCH;
			ADDER_sum<=33'd0;
			ADDER_mul<=8'd0;
		end
	end else if ((state==4'd01)||(state==4'd02)||(state==4'd03)) begin
		SNOTE <= SNOTE + 1'b1; //if не обязателен
		
		if (state==4'd01) ADDER_mul <= 8'd0255 - in_val_lo;
		if (state==4'd02) ADDER_mul <=           in_val_lo;
		
		ADDER_sum <= ADDER_sum + (ADDER_mul * ADDER_by_table);
				
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
