module midi_in(CLK, RES, MIDI_IN, 
					CH_MESSAGE, 
					CHAN, NOTE, VELOCITY, LSB, MSB  		  //параметры сообщений
					);

input wire CLK;             // 50 MHz clock
input wire RES;             // reset
input wire MIDI_IN;			 // MIDI in data 
//note control
output reg [3:0] CHAN;      // номер канала, в который отправляется нота. в ПО считаются от 1 до 16. тут считаются с 0. То есть барабаны - 10й, тут будет 9.
output reg [6:0] NOTE;      // номер ноты 0 - это С-1, 12 - С0, 24 - С1

output reg [6:0] VELOCITY;
output reg [6:0] LSB;
output reg [6:0] MSB;
output reg [3:0] CH_MESSAGE;

reg [23:0] midi_command; //миди команда 3 байта

reg [7:0] rcv_state;
//состояние приемника
//0 - ожидаем любой байт
//1 - принят первый байт сообщения канала nnnn одно из сообщений ниже, и ждем еще двух байт данных, у которых старший бит = 0, иначе это реалтайм сообщения
//    1000nnnn - Note Off						(Номер ноты(NOTE); Динамика(VELOCITY))
//    1001nnnn - Note On						(Номер ноты(NOTE); Динамика(VELOCITY))
//    1010nnnn - Polyphonic Key Pressure  (Номер ноты(NOTE); Давление(VELOCITY))
//    1011nnnn - Control Change				(Номер контроллера(LSB); Значение контроллера(MSB)) 
//    1100nnnn - Program Change 				(Номер программы(LSB); -)
//    1101nnnn - Channel Pressure			(Давление(LSB); -)
//    1110nnnn - Pitch Wheel Change			(LSB;MSB)
//2 - принят второй байт сообщения канала
//3 - принят третий байт сообщения канала и переход в 0

reg [7:0] byte1;
reg [7:0] byte2;
reg [7:0] byte3;


initial begin
	CHAN <= 4'b0000;
	NOTE <= 7'd0;
	VELOCITY <= 7'd0;
	LSB <= 7'd0;
	MSB <= 7'd0;
	CH_MESSAGE <= 4'd0;
	rcv_state <= 8'b00000000;
	byte1 <= 8'd0;
	byte2 <= 8'd0;
	byte3 <= 8'd0;
	
end

//midi rx
//бодген - модуль для генерации клока UART
// first register:
// 		baud_freq = 16*baud_rate / gcd(global_clock_freq, 16*baud_rate)
//Greatest Common Divisor - наибольший общий делитель. http://www.alcula.com/calculators/math/gcd/
//baud_freq = 16*31250 / gcd(50000000, 50000) = 500000 / 500000 = 1

// second register:
// 		baud_limit = (global_clock_freq / gcd(global_clock_freq, 16*baud_rate)) - baud_freq 
//baud_limit = (50000000 / gcd(50000000, 500000)) - 1
//           = ( 50000000 / 500000) - 1 = 99

wire port_clk;
wire [7:0] uart_command;
wire ucom_ready;

baud_gen BG( CLK, RES, port_clk, 1, 99);
uart_rx URX( CLK, RES, port_clk, MIDI_IN, uart_command, ucom_ready );


always @ (posedge CLK) begin 
	
	if (ucom_ready==1) begin
		//Ожидаем сообщение
		if (rcv_state==8'd0) begin
			//если старший бит = 1, то это сообщение
			//запоминаем байт
			if (uart_command[7:7]==1'b1) byte1 <= uart_command;
			//в любом случае сбрасываем выходы NOTE_ON, NOTE_OFF, NOTE, VELOCITY
			CH_MESSAGE <= 4'd0;
			CHAN <= 4'b0000;
			NOTE <= 7'd0;
			LSB <= 7'd00;
			MSB <= 7'd00;
			VELOCITY <= 7'd0;
			//смена стейта
			rcv_state <= ((uart_command[7:4]>=4'b1000)&&(uart_command[7:4]<=4'b1110)) ? 8'd01 : rcv_state;
		end else if (rcv_state==8'd01) begin //ждем первый байт данных
			//если старший бит = 0, то это данные
			if (uart_command[7:7]==1'b0) byte2 <= uart_command;
			
			//сменf стейта
			rcv_state <= (uart_command[7:7]==1'b0) ? 8'd2 : rcv_state;
		end else if (rcv_state==8'd02) begin //ждем второй байт данных
			//если старший бит = 0, то это данные
			if (uart_command[7:7]==1'b0) begin
				byte3 = uart_command; // = вместо <= для присвоения сразу. чтобы все данные были сразу в byte1, 2, 3
				//Обрабатываем три принятых байта
				//номер канала (в первом байте, 4 младших бита)
				CHAN <= byte1[3:0];
				//декодируем сообщение
				if ((byte1[7:4]==4'b1000)||(byte1[7:4]==4'b1001)||(byte1[7:4]==4'b1010)) begin //note off, note on, poly key pressure
					CH_MESSAGE <= byte1[7:4];
					//нота
					NOTE <= byte2[6:0];
					//значение velocity или pressure
					VELOCITY <= byte3[6:0];
				end else if ((byte1[7:4]==4'b1100)||(byte1[7:4]==4'b1101)) begin // Program change, Channel pressure
					CH_MESSAGE <= byte1[7:4];
					LSB <= byte2[6:0];
					MSB <= 0;				
				end else if ((byte1[7:4]==4'b1011)||(byte1[7:4]==4'b1110)) begin
					CH_MESSAGE <= byte1[7:4];
					LSB <= byte2[6:0];
					MSB <= byte3[6:0];				
				end
				
							
			end		
					
			//смена стейта
			rcv_state <= (uart_command[7:7]==1'b0) ? 8'd0 : rcv_state;
		end

	end //ucom_ready
	
end 

endmodule