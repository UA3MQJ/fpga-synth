module midi_in(clk, rst, midi_in, 
					ch_message, 
					chan, note, velocity, lsb, msb  		  //параметры сообщений
					);

input wire clk;             // 50 MHz clock
input wire rst;             // reset
input wire midi_in;			 // MIDI in data 
//note control
output wire [3:0] chan;      // номер канала, в который отправляется нота. в ПО считаются от 1 до 16. тут считаются с 0. То есть барабаны - 10й, тут будет 9.
output wire [6:0] note;      // номер ноты 0 - это С-1, 12 - С0, 24 - С1

output wire [6:0] velocity;
output wire [6:0] lsb;
output wire [6:0] msb;
output wire [3:0] ch_message;

reg [23:0] midi_command; //миди команда 3 байта

reg [7:0] rcv_state;
//состояние приемника
//0 - ожидаем любой байт
//1 - принят первый байт сообщения канала nnnn одно из сообщений ниже, и ждем еще двух байт данных, у которых старший бит = 0, иначе это реалтайм сообщения
//    1000nnnn - note Off						(Номер ноты(note); Динамика(velocity))
//    1001nnnn - note On						(Номер ноты(note); Динамика(velocity))
//    1010nnnn - Polyphonic Key Prstsure  (Номер ноты(note); Давление(velocity))
//    1011nnnn - Control change				(Номер контроллера(lsb); Значение контроллера(msb)) 
//    1100nnnn - Program change 				(Номер программы(lsb); -)
//    1101nnnn - channel Prstsure			(Давление(lsb); -)
//    1110nnnn - Pitch Wheel change			(lsb;msb)
//2 - принят второй байт сообщения канала
//3 - принят третий байт сообщения канала и переход в 0

reg [7:0] byte1;
reg [7:0] byte2;
reg [7:0] byte3;


initial begin
	//chan <= 4'b0000;
	//note <= 7'd0;
	//velocity <= 7'd0;
	//lsb <= 7'd0;
	//msb <= 7'd0;
	//ch_message <= 4'd0;
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
reg  midi_command_ready;
initial midi_command_ready <= 0;

baud_gen BG( clk, rst, port_clk, 1, 99);
uart_rx URX( clk, rst, port_clk, midi_in, uart_command, ucom_ready );


always @ (posedge clk) begin 
	
	if (ucom_ready==1) begin
		//Ожидаем сообщение
		if (rcv_state==8'd0) begin
			//в любом случае сбрасываем вообще все
			//chan <= 4'b0000;
			//note <= 7'd0;
			//velocity <= 7'd0;
			//lsb <= 7'd0;
			//msb <= 7'd0;
			//ch_message <= 4'd0;
			rcv_state <= 8'b00000000;
			byte1 <= 8'd0;
			byte2 <= 8'd0;
			byte3 <= 8'd0;

			//если старший бит = 1, то это сообщение
			//запоминаем байт
			if (uart_command[7:7]==1'b1) byte1 <= uart_command;
			
			//смена стейта
			rcv_state <= ((uart_command[7:4]>=4'b1000)&&(uart_command[7:4]<=4'b1110)) ? 8'd01 : rcv_state;
		end else if (rcv_state==8'd01) begin //ждем первый байт данных
			//если старший бит = 0, то это данные
			if (uart_command[7:7]==1'b0) byte2 <= uart_command;
			
			//сменf стейта
			rcv_state <= (uart_command[7:7]==1'b0) ? 8'd2 : rcv_state;
		end else if (rcv_state==8'd02) begin //ждем второй байт данных
			//если старший бит = 0, то это данные
			if (uart_command[7:7]==1'b0)	byte3 <= uart_command;
			
			midi_command_ready <= 1;
					
			//смена стейта
			rcv_state <= (uart_command[7:7]==1'b0) ? 8'd0 : rcv_state;

		end

	end //ucom_ready
	else begin
		midi_command_ready <= 0;
	end
	
end

assign chan       = (midi_command_ready) ? byte1[3:0] : 4'b0000;
assign ch_message = (midi_command_ready) ? byte1[7:4] : 4'b0000;

wire PCCP         = ((byte1[7:4]==4'b1100)||(byte1[7:4]==4'b1101)); // Program change, Channel pressure (MSB = 0)
assign lsb        = (midi_command_ready) ? byte2[6:0] : 4'b0000; 
assign msb        = (midi_command_ready&&(!PCCP)) ? byte3[6:0] : 4'b0000;

//note off, note on, poly key pressure
wire note_info = ((byte1[7:4]==4'b1000)||(byte1[7:4]==4'b1001)||(byte1[7:4]==4'b1010));
assign note = (midi_command_ready && note_info) ? byte2[6:0] : 7'b0000000;

endmodule
