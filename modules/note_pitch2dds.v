module note_pitch2dds(clk, note, pitch, lfo_sig, lfo_depth, lfo_depth_fine, adder);

input wire clk;
input wire [6:0] note;
input wire [13:0] pitch;
input wire [7:0] lfo_sig;
input wire [6:0] lfo_depth;
input wire [6:0] lfo_depth_fine;
output reg [31:0] adder;


//нота 7 нот. добавим еще 8 байт под дробную часть. 7+8 = 15 бит
//обязательно сделать проверку на выход за передлы значений!!!!

wire signed [7:0] s_note_local = note; //16й бит с запасом
wire signed [16:0] s_wide_note = s_note_local <<< 8; // нота 0..127 с 8 бит дробной частью и со знаком

wire signed [14:0] s_pitch_local = pitch;
wire signed [16:0] s_pitch = s_pitch_local - 14'D08192; //-8192..8191
//теперь надо 8192 нужно посчитать за единицу. это, кстати 14 байт
//теперь это единицу надо умножить на 12.
// * 8  то есть <<< 3 результат 17 бит
// * 4  то есть <<< 2 результат 16 бит
// и сложить. присложении получаем старший в 18-м бите
wire signed [17:0] scaled_pitch = (s_pitch <<< 3) + (s_pitch <<< 2);

wire signed [17:0] res_pitch = (scaled_pitch >>> 5);

wire signed [9:0] s_lfo = lfo_sig - 8'D128;

wire signed [9:0] s_lfo_depth = lfo_depth;
wire signed [9:0] s_lfo_depth_fine = lfo_depth_fine;

wire signed [16:0] s_res_lfo = s_lfo_depth * s_lfo ;
wire signed [16:0] s_res_lfo_fine = s_lfo_depth_fine * s_lfo ;

wire signed [19:0] s_result_note = s_wide_note + res_pitch + (s_res_lfo )+ (s_res_lfo_fine >>> 7); //получившаяся в итоге нота

wire [19:0] result_note = (s_result_note > 20'd0) ? s_result_note : 20'd0;

wire [8:0] note_int = result_note >> 8; //нота не 7 бит, а 9
wire [7:0] note_frac = result_note[7:0];


initial begin
	adder <= 32'd0;
end

wire [31:0] adder_by_table;
note2dds note2dds_table1(.clk(clk), .note(note_int), .adder(adder_by_table));
wire [31:0] adder_by_table1;
note2dds note2dds_table2(.clk(clk), .note(note_int + 1'b1), .adder(adder_by_table1));

//32+8 = 40 
wire [40:0] adder_sum = adder_by_table*(8'd255 - note_frac) + adder_by_table1*(note_frac);

always @ (posedge clk) begin

	adder <= adder_sum >> 8;
		
end

												 
endmodule
