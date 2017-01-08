module EP2C5(clk50M, key0, led0, led1, led2, MIDI_IN, 
				vcf_out, n_vcf_out,
				//iis
				DAT, MCK, SCK, LRCK,
				//PWM out
				PWM
);
//ports
input wire clk50M, key0, MIDI_IN;
output wire led0, led1, led2;

output wire vcf_out, n_vcf_out;

//iis
output wire DAT, MCK, SCK, LRCK;

//PWM
output wire PWM;

//генератор сброса
wire rst;
powerup_reset res_gen(.clk(clk50M), .key(~key0), .rst(rst));

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
						
//ловим ноту на любом					
wire NOTE_ON  = (CH_MESSAGE==4'b1001); //строб признак появления сообщения note on
wire NOTE_OFF = (CH_MESSAGE==4'b1000); //строб признак появления сообщения note off
wire GATE; // сигнал GATE в единице между note on и note off
//wire [6:0] LAST_NOTE; //последняя полученная нота

						 
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

//c1 gen for vcf			
wire [6:0] C1;
wire C1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd055))||rst; // control change & 55 control - LSB
wire [6:0] C1_value =  (rst) ? 7'd00 : MSB;
reg7 C1_reg(clk50M, C1_lsb, C1_value, C1);			

wire [31:0] vcfg_out;
reg [31:0] vcf_adder; initial vcf_adder <=32'd2748779; 

always @(posedge clk50M) begin
	//vcf_adder <= 32'd2748779 + C1 * 24'd272129; 
	vcf_adder <= 32'd1374389 + C1 * 24'd600000; 
end

dds #(.WIDTH(32)) lvcf_osc1(.clk(clk50M), .adder(vcf_adder), .signal_out(vcfg_out));

assign vcf_out = vcfg_out[31];//(hi_out<8'd64);
assign n_vcf_out = ~vcfg_out[31];//(hi_out>8'd127)&&(hi_out<=8'd255);

reg note_on_reg; initial note_on_reg <= 1'b0;

wire [31:0] adder_val;	
reg [6:0] LAST_NOTE; initial LAST_NOTE <= 7'd0;					 
note2dds  transl1(.clk(clk50M), 
                  .note(LAST_NOTE), 
						.adder(adder_val));							 


always @(posedge clk50M) begin
	if (NOTE_ON) begin
		note_on_reg <= 1'b1;
		LAST_NOTE <= NOTE;
	end else if (NOTE_OFF) begin
		note_on_reg <= 1'b0;
	end
end

assign led0 = MIDI_IN;
assign led1 = ~note_on_reg;
assign led2 = 1'b1;


wire [31:0] saw_out;
dds #(.WIDTH(32)) osc1(.clk(clk50M), .adder(adder_val), .signal_out(saw_out));

//PWM
wire [7:0] saw_out_8bit = (note_on_reg) ? saw_out[31:31-7] : 8'd127;
pwm8dac1 dac1(.clk(clk50M), 
              .in_data(saw_out_8bit), 
				  .sout(PWM));

//wire [31:0] us_data_left = data_left + 32'b10000000000000000000000000000000; //signed data in unsigned register. this is conversion		
wire [31:0] l_data = (note_on_reg) ? saw_out - 32'b10000000000000000000000000000000 : 32'b10000000000000000000000000000000;
wire [31:0] r_data = (note_on_reg) ? saw_out - 32'b10000000000000000000000000000000 : 32'b10000000000000000000000000000000;

i2s_dco #(.DATA_WIDTH(32)) iis_tx( 
							   .clk(clk50M),
							   .adder(adder_val),
								.note_on(note_on_reg),
							   .sdata(DAT),
							   .mck(MCK),
							   .sck(SCK),
							   .lrclk(LRCK)
							   );
								
								

endmodule
