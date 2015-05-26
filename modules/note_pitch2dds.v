module note_pitch2dds(clk, note, pitch, adder);

input wire clk;
input wire [6:0] note;
input wire [13:0] pitch;
output reg [31:0] adder;

reg [32:0] adder_sum;
reg [7:0]  adder_mul;

reg [3:0] state;
reg [6:0] note_local;
reg [13:0] pitch_local;

initial begin
	note_local <= 7'd0;
	pitch_local <= 14'd08192; // 0 - pitch wheel
	adder <= 32'd0;
	state <= 4'd0;
	Snote <= 9'D0;
end

//считаем pitch Wheel
// in_val сначала << 7
// а потом
//; ALGORITHM:
//; Clear accumulator
//; Add input / 1024 to accumulator >> 10
//; Add input / 2048 to accumulator >> 11
//; Move accumulator to result
//; Approximated constant: 0.00146484, Error: 0 %

//вычитаем 8192 
wire signed [14:0] in_val_centered = (pitch - 14'd08192);

//15+11 = 26 бит
wire signed [26:0] in_val_fix = in_val_centered <<< 11;

//mul 0.00146484
wire signed [26:0] in_val_mul = (in_val_fix >>> 10) + (in_val_fix >>> 11);

//старшая часть, которую прибавим к номеру ноты
wire signed [26:0] t_in_val_hi = in_val_mul >>> 11;
wire signed [7:0] in_val_hi = t_in_val_hi[7:0];

//младшая 8 битная часть, которую будем применять в линейной интерполяции
wire [7:0] in_val_lo = in_val_mul[10:3];

reg signed [8:0] Snote ; //= note;

wire [7:0] note_n = ((Snote + in_val_hi)<   0) ?    7'd0 : 
				        ((Snote + in_val_hi)> 127) ? 7'd0127 : Snote + in_val_hi;

wire [31:0] adder_by_table;
note2dds note2dds_table(clk, note_n[6:0], adder_by_table);
						
always @ (posedge clk) begin
	
	if (state==4'd00) begin
		Snote <= note;
		if ((note!=note_local)||(pitch!=pitch_local)) begin
			note_local<=note;
			pitch_local<=pitch;
			adder_sum<=33'd0;
			adder_mul<=8'd0;
		end
	end else if ((state==4'd01)||(state==4'd02)||(state==4'd03)) begin
		Snote <= Snote + 1'b1; //if не обязателен
		
		if (state==4'd01) adder_mul <= 8'd0255 - in_val_lo;
		if (state==4'd02) adder_mul <=           in_val_lo;
		
		adder_sum <= adder_sum + (adder_mul * adder_by_table);
				
	end else if (state==4'd04) begin
		adder <= adder_sum >> 8;
	end
end
	
always @ (posedge clk) begin
	//смена стейтов
	if (state==4'd00) begin
		if ((note!=note_local)||(pitch!=pitch_local)) begin
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
