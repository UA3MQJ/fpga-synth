module ym2149f(CLK50M, key0, key1, DA, CLOCK, NRES, BC1, BC2, BDIR);

input wire CLK50M, key0, key1;
inout wire [7:0] DA;
output wire CLOCK, NRES, BC1, BC2, BDIR;

//1.75 mhz
wire clk1M;
clk50Mto1M conv(.inclk0(CLK50M), .c0(clk1M));


wire rst;
powerup_reset reset_gen(.clk(clk1M), .key(~key0), .rst(rst));
assign NRES = ~rst;

/*
//16 регистров управления. это 4 бита
reg [3:0] reg_addr;
initial   reg_addr <= 4'b0000;

//массив регистров в плис
reg  [7:0] reg_arr [0:15];
wire [7:0] reg_data = reg_arr[reg_addr];
wire [7:0] reg_addr8 = {4'b0000, reg_addr};

initial begin
	reg_arr[00] <= 8'b00111100; //A
	reg_arr[01] <= 8'b00001111;
	reg_arr[02] <= 8'b11111111; //B
	reg_arr[03] <= 8'b00001111;
	reg_arr[04] <= 8'b11111111; //C
	reg_arr[05] <= 8'b00001111;
	reg_arr[06] <= 8'b00001111;  //noise 5 bit
	reg_arr[07] <= 8'b00000000;  //mask
	reg_arr[08] <= 8'b00000011;  //vol A
	reg_arr[09] <= 8'b00000011;  //vol B
	reg_arr[10] <= 8'b00000011;  //VOL C
	reg_arr[11] <= 8'b00000000; //freq env
	reg_arr[12] <= 8'b00000000; //freq end
	reg_arr[13] <= 8'b00000000; //shape
	reg_arr[14] <= 8'b00000000; //data port a
	reg_arr[15] <= 8'b00000000; //data port b
end
*/


//assign DA = (rBC1==1'b1) ? reg_addr8 : reg_data ;

reg [7:0] rDA;
initial rDA <= 8'd0;


reg [2:0] key_arr;
initial  key_arr <= 3'b000;
wire key1_posedge = (key_arr==3'b011);

assign CLOCK = clk1M;

always @(posedge clk1M) begin
	key_arr <= {key_arr[1:0],~key1}; 
end

reg rBDIR;
reg rBC1;
reg rBC2;
reg hiz;

assign BDIR = rBDIR;
assign BC1 = rBC1;
assign BC2 = rBC2; 
assign DA = (hiz) ? 8'bzzzzzzzz : rDA;
//clk1M

initial begin
	rBDIR <= 0;
	rBC1  <= 0;
	rBC2  <= 0; //неактивен
	hiz <= 1;
end



//стейтмашина на 16 состояний
reg [7:0] state;
initial state<=8'd0;

reg [4:0] noise_freq;
initial noise_freq <= 5'b00011;


always @(posedge clk1M) begin

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
		rDA <= 8'd08; //level of ch A
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
	
end

endmodule

/*

	if ((state==0)&&(key1_posedge)) begin
		state <= 1;
	end else if(state==1) begin
		rDA <= 6;
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		
		
		state <= 2;		
	end else if(state==2) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 1; //неактивен

		state <= 3;		
	end else if(state==3) begin
		rDA   <= 8'b00001111;
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных		

		state <= 4;		
	end else if(state==4) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 1; //неактивен

		state <= 5;		
	end else if(state==5) begin
		rDA <= 7;
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		

		state <= 6;		
	end else if(state==6) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 1; //неактивен

		state <= 7;		
	end else if(state==7) begin
		rDA   <= 8'b00000111;
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных		

		state <= 8;		
	end else if(state==8) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 1; //неактивен

		state <= 9;		
	end else if(state==9) begin
		rDA <= 8;
		rBDIR <= 1;
		rBC1  <= 1;
		rBC2  <= 1; //фиксация адреса		

		state <= 10;		
	end else if(state==10) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 1; //неактивен

		state <= 11;		
	end else if(state==11) begin
		rDA   <= 8'b00001111;
		rBDIR <= 1;
		rBC1  <= 0;
		rBC2  <= 1; //запись данных		

		state <= 12;		
	end else if(state==12) begin
		rBDIR <= 0;
		rBC1  <= 0;
		rBC2  <= 1; //неактивен

		state <= 13;		
	end else if(state==13) begin

		state <= 14;		
	end else if(state==14) begin

		state <= 15;		
	end else if(state==15) begin

		state <= 16;		
	end else if(state==16) begin

		state <= 17;		
	end else if(state==17) begin

		state <= 0;		
	end
	
end

*/
