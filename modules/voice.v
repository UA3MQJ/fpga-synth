module voice(clk, gate, note, pitch, lfo_sig, lfo_depth, lfo_depth_fine,  wave_form, signal_out);
input wire clk;
input wire gate;
input wire [6:0] note;
input wire [7:0] lfo_sig;
input wire [6:0] lfo_depth;
input wire [6:0] lfo_depth_fine;
input wire [13:0] pitch;
output wire [7:0] signal_out;
//input wire [31:0] adder;
input wire [2:0] wave_form;

// wave_forms
parameter SAW      = 3'b000;
parameter SQUARE   = 3'b001; //with PWM
parameter TRIANGLE = 3'b010;
parameter SINE     = 3'b011;
parameter RAMP     = 3'b100;
parameter SAW_TRI  = 3'b101;
parameter NOISE    = 3'b110;
parameter UNDEF    = 3'b111;

wire [31:0] adder_center;
note_pitch2dds  transl1(.clk(clk), .note(note), .pitch(pitch), .lfo_sig(lfo_sig), .lfo_depth(lfo_depth), .lfo_depth_fine(lfo_depth_fine), .adder(adder_center)); 

wire [31:0] vco_out;
dds #(.WIDTH(32)) vco(.clk(clk), .adder(adder_center), .signal_out(vco_out));


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
                    (wave_form ==    NOISE) ? noise_out : 8'd127;

endmodule
