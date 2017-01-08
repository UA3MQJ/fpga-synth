module EP2C5(clk50M, key0, led0, led1, led2, MIDI_IN, 
				//VCA
				/* a1, a2, a3, a4, ac1, ac2, ac3, ac4, */
				//ym2149f
				DA, CLOCK, NRES, BC1, BC2, BDIR, clk1750K,
				vcf_out, n_vcf_out
);
//ports
input wire clk50M, key0, MIDI_IN;
output wire led0, led1, led2;

output wire vcf_out, n_vcf_out;

//генератор сброса
wire rst;
powerup_reset res_gen(.clk(clk50M), .key(~key0), .rst(rst));

//ym2149f
input wire clk1750K;
inout wire [7:0] DA;
output wire CLOCK, NRES, BC1, BC2, BDIR;

assign CLOCK = clk1750K;
assign NRES = ~rst;



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

//Env controls
//ENV mode = 0..63 - ADSR. 64..127 - AY ENV
wire [6:0] ENV_MODE;
wire ENV_MODE_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd020))||rst; // control change & 20 control - LSB
wire [6:0] ENV_MODE_value =  (rst) ? 7'b0000000 : MSB;
reg7 ENV_MODE_reg(clk50M, ENV_MODE_lsb, ENV_MODE_value, ENV_MODE);
wire ENV_ADSR_MODE = (ENV_MODE < 7'd064);

//ENV form - use only 3 high bits
wire [6:0] ENV_FRM;
wire ENV_FRM_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd021))||rst; // control change & 21 control - LSB
wire [6:0] ENV_FRM_value =  (rst) ? 7'b0000000 : MSB;
reg7 ENV_FRM_reg(clk50M, ENV_FRM_lsb, ENV_FRM_value, ENV_FRM);

//value for Envelope Shape Control Register
wire [2:0] ENV_FRM_hi3 = ENV_FRM[6:4];
wire [7:0] ENV_SCR = (ENV_FRM_hi3 == 3'b000) ? 8'b00000000 :  //  - \___
							(ENV_FRM_hi3 == 3'b001) ? 8'b00001111 :  //  - /|___
							(ENV_FRM_hi3 == 3'b010) ? 8'b00001011 :  //  - \|^^^
							(ENV_FRM_hi3 == 3'b011) ? 8'b00001101 :  //  - /^^^^
							(ENV_FRM_hi3 == 3'b100) ? 8'b00001000 :  //  - \|\|\
							(ENV_FRM_hi3 == 3'b101) ? 8'b00001100 :  //  - /|/|/
							(ENV_FRM_hi3 == 3'b110) ? 8'b00001010 :  //  - \/\/\
							(ENV_FRM_hi3 == 3'b111) ? 8'b00001110 : 8'b00000000; //  - /\/\/

//ENV speed hi7 bits
wire [6:0] ENV_SP1;
wire ENV_SP1_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd022))||rst; // control change & 22 control - LSB
wire [6:0] ENV_SP1_value =  (rst) ? 7'd063 : MSB;
reg7 ENV_SP1_reg(clk50M, ENV_SP1_lsb, ENV_SP1_value, ENV_SP1);
//ENV speed lo7 bits
wire [6:0] ENV_SP2;
wire ENV_SP2_lsb = ((CH_MESSAGE==4'b1011)&&(LSB==7'd023))||rst; // control change & 23 control - LSB
wire [6:0] ENV_SP2_value =  (rst) ? 7'b0000000 : MSB;
reg7 ENV_SP2_reg(clk50M, ENV_SP2_lsb, ENV_SP2_value, ENV_SP2);

wire [7:0] ENV_SP_LO = {ENV_SP1[0], ENV_SP2};
wire [7:0] ENV_SP_HI = {2'b00, ENV_SP1[6:1]};
			
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

wire [7:0] hi_out = vcfg_out[31:24];
assign vcf_out = vcfg_out[31];//(hi_out<8'd64);
assign n_vcf_out = ~vcfg_out[31];//(hi_out>8'd127)&&(hi_out<=8'd255);


//YM
//управляющее
reg [7:0] rDA;
initial rDA <= 8'd0;


reg rBDIR;
reg rBC1;
reg rBC2;
reg hiz;

assign BDIR = rBDIR;
assign BC1 = rBC1;
assign BC2 = rBC2; 
assign DA = (hiz) ? 8'bzzzzzzzz : rDA;

initial begin
	rBDIR <= 0;
	rBC1  <= 0;
	rBC2  <= 0; //неактивен
	hiz <= 1;
end

// декодируем миди

//нажатые клавиши канала 1,2,3
reg [127:0] chan1_keys; initial chan1_keys <= 128'd0;
reg [127:0] chan2_keys; initial chan2_keys <= 128'd0;
reg [127:0] chan3_keys; initial chan3_keys <= 128'd0;
wire chan1_GATE = (chan1_keys!=128'd0);
wire chan2_GATE = (chan2_keys!=128'd0);
wire chan3_GATE = (chan3_keys!=128'd0);


//chan1
wire [127:0] chan1_hi_note_bits;
wire [6:0] chan1_hi_note;
bitscan #(.WIDTH(128)) bs1(.in(chan1_keys), .out(chan1_hi_note_bits));
prio_encoder #(.LINES(128)) pe1(.in(chan1_hi_note_bits), .out(chan1_hi_note));

wire [11:0] chan1_TP;
ay_note_ram ram1(.addr(chan1_hi_note), .data(chan1_TP));
reg [11:0] chan1_tp_last; initial chan1_tp_last <= 12'd0; //регистр для сохранения последней ноты, для возможности работы послезвучия ADSR
always @(posedge clk1750K) if (chan1_GATE) chan1_tp_last <= chan1_TP;

//chan2
wire [127:0] chan2_hi_note_bits;
wire [6:0] chan2_hi_note;
bitscan #(.WIDTH(128)) bs2(.in(chan2_keys), .out(chan2_hi_note_bits));
prio_encoder #(.LINES(128)) pe2(.in(chan2_hi_note_bits), .out(chan2_hi_note));

wire [11:0] chan2_TP;
ay_note_ram ram2(.addr(chan2_hi_note), .data(chan2_TP));
reg [11:0] chan2_tp_last; initial chan2_tp_last <= 12'd0; //регистр для сохранения последней ноты, для возможности работы послезвучия ADSR
always @(posedge clk1750K) if (chan2_GATE) chan2_tp_last <= chan2_TP;

//chan3
wire [127:0] chan3_hi_note_bits;
wire [6:0] chan3_hi_note;
bitscan #(.WIDTH(128)) bs3(.in(chan3_keys), .out(chan3_hi_note_bits));
prio_encoder #(.LINES(128)) pe3(.in(chan3_hi_note_bits), .out(chan3_hi_note));

wire [11:0] chan3_TP;
ay_note_ram ram3(.addr(chan3_hi_note), .data(chan3_TP));
reg [11:0] chan3_tp_last; initial chan3_tp_last <= 12'd0; //регистр для сохранения последней ноты, для возможности работы послезвучия ADSR
always @(posedge clk1750K) if (chan3_GATE) chan3_tp_last <= chan3_TP;


always @(posedge clk50M) begin

	if (rst) begin
		chan1_keys <= 128'd0;
		chan2_keys <= 128'd0;
		chan3_keys <= 128'd0;
	end else if (NOTE_ON) begin
		if(CHAN==4'd0) begin
			chan1_keys[NOTE] <= 1'b1;
		end else if(CHAN==4'd1) begin
			chan2_keys[NOTE] <= 1'b1;
		end else	if(CHAN==4'd2) begin
			chan3_keys[NOTE] <= 1'b1;
		end
	end else if (NOTE_OFF) begin
		if(CHAN==4'd0) begin
			chan1_keys[NOTE] <= 1'b0;
		end else if(CHAN==4'd1) begin
			chan2_keys[NOTE] <= 1'b0;
		end else	if(CHAN==4'd2) begin
			chan3_keys[NOTE] <= 1'b0;
		end
	end
end


//GATE1 									 
reg [1:0] chan1_GATE_edge; initial chan1_GATE_edge <= 2'b00;

always @(posedge clk1750K) chan1_GATE_edge <= {chan1_GATE_edge[0], chan1_GATE};

wire chan1_GATE_posedge = (chan1_GATE_edge==2'b01) /* synthesis keep */;
wire chan1_GATE_negedge = (chan1_GATE_edge==2'b10) /* synthesis keep */;
//GATE2 									 
reg [1:0] chan2_GATE_edge; initial chan2_GATE_edge <= 2'b00;

always @(posedge clk1750K) chan2_GATE_edge <= {chan2_GATE_edge[0], chan2_GATE};

wire chan2_GATE_posedge = (chan2_GATE_edge==2'b01) /* synthesis keep */;
wire chan2_GATE_negedge = (chan2_GATE_edge==2'b10) /* synthesis keep */;
//GATE3 									 
reg [1:0] chan3_GATE_edge; initial chan3_GATE_edge <= 2'b00;

always @(posedge clk1750K) chan3_GATE_edge <= {chan3_GATE_edge[0], chan3_GATE};

wire chan3_GATE_posedge = (chan3_GATE_edge==2'b01) /* synthesis keep */;
wire chan3_GATE_negedge = (chan3_GATE_edge==2'b10) /* synthesis keep */;
//

//tone CHANGE 1 									 
reg [11:0] chan1_TONE_change; initial chan1_TONE_change <= 12'd0;
always @(posedge clk1750K) chan1_TONE_change <= chan1_tp_last;
wire chan1_NOTE_change_flag = (chan1_TONE_change!=chan1_tp_last) /* synthesis keep */;

//tone CHANGE 2 									 
reg [11:0] chan2_TONE_change; initial chan2_TONE_change <= 12'd0;
always @(posedge clk1750K) chan2_TONE_change <= chan2_tp_last;
wire chan2_NOTE_change_flag = (chan2_TONE_change!=chan2_tp_last) /* synthesis keep */;

//tone CHANGE 3
reg [11:0] chan3_TONE_change; initial chan3_TONE_change <= 12'd0;
always @(posedge clk1750K) chan3_TONE_change <= chan3_tp_last;
wire chan3_NOTE_change_flag = (chan3_TONE_change!=chan3_tp_last) /* synthesis keep */;

//ADSR 1
wire [31:0] adsr1out;
adsr32 adsr1(clk50M, chan1_GATE, A1, D1, {S1,25'b0}, R1, adsr1out);
wire [3:0] adsr1_AY = adsr1out[31:28];

reg [3:0] adsr1_AY_change; initial adsr1_AY_change <= 4'd0;
always @(posedge clk1750K) adsr1_AY_change <= adsr1_AY;
wire adsr1_AY_change_flag = (adsr1_AY_change != adsr1_AY);

//ADSR 2
wire [31:0] adsr2out;
adsr32 adsr2(clk50M, chan2_GATE, A1, D1, {S1,25'b0}, R1, adsr2out);
wire [3:0] adsr2_AY = adsr2out[31:28];

reg [3:0] adsr2_AY_change; initial adsr2_AY_change <= 4'd0;
always @(posedge clk1750K) adsr2_AY_change <= adsr2_AY;
wire adsr2_AY_change_flag = (adsr2_AY_change != adsr2_AY);

//ADSR 1
wire [31:0] adsr3out;
adsr32 adsr3(clk50M, chan3_GATE, A1, D1, {S1,25'b0}, R1, adsr3out);
wire [3:0] adsr3_AY = adsr3out[31:28];

reg [3:0] adsr3_AY_change; initial adsr3_AY_change <= 4'd0;
always @(posedge clk1750K) adsr3_AY_change <= adsr3_AY;
wire adsr3_AY_change_flag = (adsr3_AY_change != adsr3_AY);

//env period changed
reg [15:0] endv_period_change; initial endv_period_change <= 16'd0;
always @(posedge clk1750K) endv_period_change <= {ENV_SP_HI, ENV_SP_LO};
wire endv_period_change_flag = (endv_period_change != {ENV_SP_HI, ENV_SP_LO});

//env form changed ENV_SCR
reg [7:0] ENV_SCR_change; initial ENV_SCR_change <= 8'd0;
always @(posedge clk1750K) ENV_SCR_change <= ENV_SCR;
wire ENV_SCR_change_flag = (ENV_SCR_change != ENV_SCR);

//env mode changed ENV_ADSR_MODE
reg ENV_ADSR_MODE_change; initial ENV_ADSR_MODE_change <= 1'd0;
always @(posedge clk1750K) ENV_ADSR_MODE_change <= ENV_ADSR_MODE;
wire ENV_ADSR_MODE_change_flag = (ENV_ADSR_MODE_change != ENV_ADSR_MODE);


assign led0 = ~(chan1_GATE || (~MIDI_IN));//MIDI_IN;
assign led1 = ~(chan2_GATE || (~MIDI_IN));//~note_on_reg;
assign led2 = ~(chan2_GATE || (~MIDI_IN));//1'b1;

//кусок как бы памяти
reg  [3:0] ram_addr /* synthesis noprune */; initial ram_addr <= 4'b0000;
wire [7:0] ram_data;
reg  [7:0] ram_arr [0:15];
assign ram_data = ram_arr[ram_addr]  /* synthesis noprune */;
initial begin
	ram_arr[4'd00] <= 8'd0;
	ram_arr[4'd01] <= 8'd0;
	ram_arr[4'd02] <= 8'd0;
	ram_arr[4'd03] <= 8'd0;
	ram_arr[4'd04] <= 8'd0;
	ram_arr[4'd05] <= 8'd0;
	ram_arr[4'd06] <= 8'd0;
	ram_arr[4'd07] <= 8'd0;
	ram_arr[4'd08] <= 8'd0;
	ram_arr[4'd09] <= 8'd0;
	ram_arr[4'd10] <= 8'd0;
	ram_arr[4'd11] <= 8'd0;
	ram_arr[4'd12] <= 8'd0;
	ram_arr[4'd13] <= 8'd0;
	ram_arr[4'd14] <= 8'd0;
	ram_arr[4'd15] <= 8'd0;
end

reg [7:0] nR0  /* synthesis noprune */;
reg [7:0] nR1  /* synthesis noprune */;
reg [7:0] nR2  /* synthesis noprune */;
reg [7:0] nR3  /* synthesis noprune */;
reg [7:0] nR4  /* synthesis noprune */;
reg [7:0] nR5  /* synthesis noprune */;
reg [7:0] nR6  /* synthesis noprune */;
reg [7:0] nR7  /* synthesis noprune */;
reg [7:0] nR8  /* synthesis noprune */;
reg [7:0] nR9  /* synthesis noprune */;
reg [7:0] nRA  /* synthesis noprune */;
reg [7:0] nRB  /* synthesis noprune */;
reg [7:0] nRC  /* synthesis noprune */;
reg [7:0] nRD  /* synthesis noprune */;
reg [7:0] nRE  /* synthesis noprune */;
reg [7:0] nRF  /* synthesis noprune */;

initial begin
	nR0 <= 8'd0; nR1 <= 8'd0; nR2 <= 8'd0; nR3 <= 8'd0; nR4 <= 8'd0; nR5 <= 8'd0; nR6 <= 8'd0; nR7 <= 8'd0; nR8 <= 8'd0; nR9 <= 8'd0; nRA <= 8'd0; nRB <= 8'd0; nRC <= 8'd0; nRD <= 8'd0; nRE <= 8'd0;  nRF <= 8'd0; 
end

//памим регистры от текущего адреса
wire [7:0] nRX_data = 
					 (ram_addr == 4'd00) ? nR0 :
					 (ram_addr == 4'd01) ? nR1 :
					 (ram_addr == 4'd02) ? nR2 :
					 (ram_addr == 4'd03) ? nR3 :
					 (ram_addr == 4'd04) ? nR4 :
					 (ram_addr == 4'd05) ? nR5 :
					 (ram_addr == 4'd06) ? nR6 :
					 (ram_addr == 4'd07) ? nR7 :
					 (ram_addr == 4'd08) ? nR8 :
					 (ram_addr == 4'd09) ? nR9 :
					 (ram_addr == 4'd10) ? nRA :
					 (ram_addr == 4'd11) ? nRB :
					 (ram_addr == 4'd12) ? nRC :
					 (ram_addr == 4'd13) ? nRD :
					 (ram_addr == 4'd14) ? nRE :
					 (ram_addr == 4'd15) ? nRF : 8'd0;

reg [7:0] state; initial state <= 8'd0;

always @(posedge clk1750K) begin

	if (rst) begin
		nR0 <= 8'd0; nR1 <= 8'd0; nR2 <= 8'd0; nR3 <= 8'd0; nR4 <= 8'd0; nR5 <= 8'd0; nR6 <= 8'd0; nR7 <= 8'd0; nR8 <= 8'd0; nR9 <= 8'd0; nRA <= 8'd0; nRB <= 8'd0; nRC <= 8'd0; nRD <= 8'd0; nRE <= 8'd0;  nRF <= 8'd0; 
	end
	
	if (chan1_GATE_posedge||
		 chan2_GATE_posedge||
		 chan3_GATE_posedge||
		 chan1_GATE_negedge||
		 chan2_GATE_negedge||
		 chan3_GATE_negedge
		 )
	begin

			nR7 <= 8'b00111000; //0,0, Noise A,B,C, tone A,B,C
			//ENV_ADSR_MODE
			
	end //else 
	
	if (ENV_ADSR_MODE_change_flag)
	begin
		nRB <= ENV_SP_LO;//период огибающей младшая
		nRC <= ENV_SP_HI;//период огибающей старшая
		nRD <= 8'b00001001;//форма огибающей
	end
	
	if (chan1_NOTE_change_flag) begin
			//chan1_tp_last 12 бит
			nR0 <= chan1_tp_last[7:0];
			nR1 <= {4'b0000, chan1_tp_last[11:8]};
	end //else 

	if (chan2_NOTE_change_flag) begin
			//chan2_TP 12 бит
			nR2 <= chan2_tp_last[7:0];
			nR3 <= {4'b0000, chan2_tp_last[11:8]};
	end //else 

	if (chan3_NOTE_change_flag) begin
			//chan3_TP 12 бит
			nR4 <= chan3_tp_last[7:0];
			nR5 <= {4'b0000, chan3_tp_last[11:8]};
	end //else 	
	
	if (endv_period_change_flag) begin
		nRB <= ENV_SP_LO;//период огибающей младшая
		nRC <= ENV_SP_HI;//период огибающей старшая
	end
	
	if (ENV_SCR_change_flag) begin
		nRD <= ENV_SCR;//форма огибающей
	end
	
	if (adsr1_AY_change_flag) begin
		if (ENV_ADSR_MODE) begin // если режим ADSR, то не используем огибающую
			nR8 <= {4'b0000, adsr1_AY};//8'b00001111; //level A 
		end else begin //иначе выводим звук при ненулевом выходе ADSR, а огибающая аппаратная AY
			if (adsr1_AY==4'b0000) begin //если утухли - гасим звук
				nR8 <= 8'b00000000;
				nRD <= 8'b00001001; //сбрасываем форму, чтоб сработала заново на следующей ноте
			end else begin
				nRD <= ENV_SCR;//форма огибающей ставится, чтобы перезапустить ее в начале ноты
				nR8 <= 8'b00010000; //автогенерация уровня по огибающей
			end
		end
	end

	if (adsr2_AY_change_flag) begin
		nR9 <= {4'b0000, adsr2_AY};//8'b00001111; //level B
	end

	if (adsr3_AY_change_flag) begin
		nRA <= {4'b0000, adsr3_AY};//8'b00001111; //level C 
	end
	
	if (state == 8'd0) begin
		if (ram_data == nRX_data) begin
			ram_addr <= ram_addr + 1'b1;
		end else begin
			ram_arr[ram_addr] <= nRX_data;
		end
		
		state <= (ram_data != nRX_data) ? 8'd1 : state;
	end else if (state == 8'd1) begin
		rDA    <= {4'b0000, ram_addr};
		rBDIR  <= 1;
		rBC1   <= 1;
		rBC2   <= 1; //фиксация адреса		
		hiz    <= 0;
	
		state  <= 8'd2;
	end else if (state == 8'd2) begin
		rBDIR  <= 0;
		rBC1   <= 0;
		rBC2   <= 0; //неактивен
		hiz    <= 1;

		state  <= 8'd3;
	end else if (state == 8'd3) begin
		rDA    <= nRX_data;
		rBDIR  <= 1;
		rBC1   <= 0;
		rBC2   <= 1; //запись данных
		hiz    <= 0;
	
		state  <= 8'd4;
	end else if (state == 8'd4) begin
		rBDIR  <= 0;
		rBC1   <= 0;
		rBC2   <= 0; //неактивен
		hiz    <= 1;

		state  <= 8'd0;
	end
	
end

endmodule



/*


	if (chan1_GATE_posedge) begin
			nR6 <= 8'b00000011;
			nR7 <= 8'b00000000;
			nR8 <= 8'b00010000;
			nRC <= 8'b00010000;
			nRD <= 8'b00001010;
	end else
	if (chan1_GATE_negedge) begin
			nR6 <= 8'b00000000;
			nR7 <= 8'b00000000;
			nR8 <= 8'b00000000;
			nRC <= 8'b00000000;
			nRD <= 8'b00000000;
	end else
	if(state==0) begin  //проверка регистра 0
		if (nR0 != cR0) begin
			rADDR <= 8'd0;
			rDATA <= nR0;
			cR0   <= nR0;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end
	end else if(state==1) begin  //проверка регистра 1
		if (nR1 != cR1) begin
			rADDR <= 8'd1;
			rDATA <= nR1;
			cR1   <= nR1;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==2) begin  //проверка регистра 2
		if (nR2 != cR2) begin
			rADDR <= 8'd2;
			rDATA <= nR2;
			cR2   <= nR2;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==3) begin  //проверка регистра 3
		if (nR3 != cR3) begin
			rADDR <= 8'd3;
			rDATA <= nR3;
			cR3   <= nR3;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==4) begin  //проверка регистра 4
		if (nR4 != cR4) begin
			rADDR <= 8'd4;
			rDATA <= nR4;
			cR4   <= nR4;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==5) begin  //проверка регистра 5
		if (nR5 != cR5) begin
			rADDR <= 8'd5;
			rDATA <= nR5;
			cR5   <= nR5;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==6) begin  //проверка регистра 6
		if (nR6 != cR6) begin
			rADDR <= 8'd6;
			rDATA <= nR6;
			cR6   <= nR6;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==7) begin  //проверка регистра 7
		if (nR7 != cR7) begin
			rADDR <= 8'd7;
			rDATA <= nR7;
			cR7   <= nR7;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==8) begin  //проверка регистра 8
		if (nR8 != cR8) begin
			rADDR <= 8'd8;
			rDATA <= nR8;
			cR8   <= nR8;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==9) begin  //проверка регистра 9
		if (nR9 != cR9) begin
			rADDR <= 8'd9;
			rDATA <= nR9;
			cR9   <= nR9;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==10) begin  //проверка регистра 10
		if (nRA != cRA) begin
			rADDR <= 8'd10;
			rDATA <= nRA;
			cRA   <= nRA;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==11) begin  //проверка регистра 11
		if (nRB != cRB) begin
			rADDR <= 8'd11;
			rDATA <= nRB;
			cRB   <= nRB;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==12) begin  //проверка регистра 12
		if (nRC != cRC) begin
			rADDR <= 8'd12;
			rDATA <= nRC;
			cRC   <= nRC;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==13) begin  //проверка регистра 13
		if (nRD != cRD) begin
			rADDR <= 8'd13;
			rDATA <= nRD;
			cRD   <= nRD;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==14) begin  //проверка регистра 14
		if (nRE != cRE) begin
			rADDR <= 8'd14;
			rDATA <= nRE;
			cRE   <= nRE;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==15) begin  //проверка регистра 15
		if (nRF != cRF) begin
			rADDR <= 8'd15;
			rDATA <= nRF;
			cRF   <= nRF;
			state <= 18;
		end else begin
			state <= state + 1'b1;
		end		
	end else if(state==17) begin  //стейт заглушка		
		state <= 0;
	end else if (state==18) begin //стейт, из которого записываются данные в AY
		if(sstate==0) begin
			rDA    <= rADDR;
			rBDIR  <= 1;
			rBC1   <= 1;
			rBC2   <= 1; //фиксация адреса		
			hiz    <= 0;
			sstate <= 1;
		end else if(sstate==1) begin
			rBDIR  <= 0;
			rBC1   <= 0;
			rBC2   <= 0; //неактивен
			hiz    <= 1;
			sstate <= 2;
		end else if(sstate==2) begin
			rDA    <= rDATA;
			rBDIR  <= 1;
			rBC1   <= 0;
			rBC2   <= 1; //запись данных
			hiz    <= 0;
			sstate <= 3;
		end else if(sstate==3) begin
			rBDIR  <= 0;
			rBC1   <= 0;
			rBC2   <= 0; //неактивен
			hiz    <= 1;
			sstate <= 4;
		end else if(sstate==4) begin
			sstate <= 0;
			state  <= 0;
		end
	end


*/


/*
	reg [4:0] noise_freq;
	initial noise_freq <= 5'b00011;


	if ((state==0)&&(key1_posedge)) begin
		state <= 1;
	end else if(state==1) begin
		rDA <= 8'd06; //noise
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		hiz <= 0;
		
		noise_freq <= noise_freq + 1'b1;
		
		state <= 2;		
	end else if(state==2) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;

		state <= 3;		
	end else if(state==3) begin
		rDA <= {4'b000, noise_freq};
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных
		hiz <= 0;

		state <= 4;		
	end else if(state==4) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;

		state <= 5;		
	end else if(state==5) begin
		//rBDIR <= 0;
		//rBC1  <= 1;
		//rBC2  <= 1; //чтение
		//hiz <= 1;
		rDA <= 8'd07; //mixer
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		hiz <= 0;

		state <= 6;		
	end else if(state==6) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;

		state <= 7;		
	end else if(state==7) begin
		rDA <= 8'b00000000; // all --noise only
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных
		hiz <= 0;

		state <= 8;		
	end else if(state==8) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;

		state <= 9;		
	end else if(state==9) begin
		rDA <= 8'd09; //level of ch A
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		hiz <= 0;

		state <= 10;		
	end else if(state==10) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;

		state <= 11;		
	end else if(state==11) begin
		rDA <= 8'b00010000;//8'b00001111; //постоянная
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных
		hiz <= 0;

		state <= 12;		
	end else if(state==12) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;
	
		state <= 13;		

	end else if(state==13) begin
		rDA <= 8'd09; //level of ch C
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		hiz <= 0;

		state <= 14;		
	end else if(state==14) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;

		state <= 15;		
	end else if(state==15) begin
		rDA <= 8'b00010000;//8'b00001111; //постоянная
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных
		hiz <= 0;

		state <= 16;		
	end else if(state==16) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;
	
		state <= 17;		
	

	end else if(state==17) begin
		rDA <= 8'd012; //огибающая
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		hiz <= 0;

		state <= 18;		
	end else if(state==18) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;
	
		state <= 19;		
	end else if(state==19) begin
		rDA <= 8'b00011111;
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных
		hiz <= 0;

		state <= 20;		
	end else if(state==20) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;
	

		state <= 21;		
	end else if(state==21) begin
		rDA <= 8'd013; //форма
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		hiz <= 0;

		state <= 22;		
	end else if(state==22) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;
	
		state <= 23;		
	end else if(state==23) begin
		rDA <= 8'b00001010;
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных
		hiz <= 0;

		state <= 24;		
	end else if(state==24) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 0; //неактивен
		hiz <= 1;
	

		state <= 25;		
	end else if(state==25) begin

		state <= 0;		
	end 
*/