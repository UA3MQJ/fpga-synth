module note_mono(clk, note_on, note_off, note, out_note, out_gate);
parameter MAX_NOTES = 32;
parameter MNOTES = MAX_NOTES - 1;
parameter BIT_WIDTH  = (MAX_NOTES[7:7]==1'b1) ? 8 : 
					   (MAX_NOTES[6:6]==1'b1) ? 7 :
					   (MAX_NOTES[5:5]==1'b1) ? 6 :
					   (MAX_NOTES[4:4]==1'b1) ? 5 :
					   (MAX_NOTES[3:3]==1'b1) ? 4 :
					   (MAX_NOTES[2:2]==1'b1) ? 3 :
					   (MAX_NOTES[1:1]==1'b1) ? 2 :
					   (MAX_NOTES[0:0]==1'b1) ? 1 : 0;
					   				   

//inputs outputs
input wire clk, note_on, note_off;
input wire [6:0] note;
output wire [6:0] out_note;
output reg out_gate;

initial out_gate <= 0;

reg [(BIT_WIDTH-1):0] addr;
initial addr <= 0;

reg [BIT_WIDTH:0] top_ptr;
initial top_ptr <= 0;

reg [6:0] list [0:MNOTES];

reg [6:0] t_note;
reg [6:0] t_out_note;
reg [6:0] max_note;

assign out_note = (out_gate) ? t_out_note : 7'd0;

//debug
wire [6:0] A = list[0];
wire [6:0] B = list[1];
wire [6:0] C = list[2];
wire [6:0] D = list[3];

//state list
parameter INITIAL  = 2'd0;
parameter NOTE_ON  = 2'd1;
parameter NOTE_OFF = 2'd2;
parameter READY    = 2'd3;
reg [1:0] state;
initial state <= INITIAL;

//note_on state list
parameter ST_SEARCH  = 2'd0; //начало поиска
parameter IN_SEARCH  = 2'd1; //процес поиска
parameter END_SEARCH = 2'd2; //если не нашли, то добавляем
parameter GETMAX   = 2'd3; //ищем максимальную
reg [1:0] note_on_state;
initial note_on_state <= 0;
reg searched;

//note_off state list
//parameter ST_SEARCH  = 2'd0; //начало поиска
//parameter IN_SEARCH  = 2'd1; //процес поиска
//parameter END_SEARCH = 2'd2; //если не нашли, то добавляем
//parameter GETMAX   = 2'd3; //ищем максимальную
reg [1:0] note_off_state;
initial note_off_state <= 0;


always @(posedge clk) begin
	if (note_on||note_off) begin
		t_note <= note;
	end
end

always @(posedge clk) begin
	if (state==INITIAL) begin
		addr <= 0;
		top_ptr <= 0;
		out_gate <= 0;
		state <= READY;
	end else if (state==READY) begin
		if (note_on) begin
			state <= NOTE_ON;
			addr <= 0;
			searched <= 0;
			note_on_state <= 0;
		end else if (note_off) begin
			state <= NOTE_OFF;
			addr <= 0;
			searched <= 0;
			note_off_state <= 0;
		end
	end else if (state==NOTE_ON) begin
		if (note_on_state == ST_SEARCH) begin
			if (top_ptr==0) begin //случай, когда нот нет
				out_gate <= 1;
				t_out_note <= t_note;
				list[addr] <= t_note;
				top_ptr <= top_ptr + 1'b1;
				state <= READY;
			end else begin
				max_note <= t_note; //инициируем max_note для поиска наибольшей ноты из всех
				addr <= addr + 1'b1;
				note_on_state <= IN_SEARCH;
				if (list[addr]==t_note) searched <= 1;
			end
		end else if (note_on_state == IN_SEARCH) begin
			if (addr==top_ptr) begin //значит весь массив уже пройден. элемент по адресу уже не анализируется (тк top_ptr на 1 больше)
				note_on_state <= END_SEARCH;
			end else begin
				if (list[addr] > max_note) max_note <= list[addr];
				if (list[addr]==t_note) searched <= 1;
				addr <= addr + 1'b1;
			end
		end else if (note_on_state == END_SEARCH) begin
			if (searched) begin //если нашли, значит уже нажата, не добавляем и ничего не делаем
				state <= READY;
			end else begin // если не нашли, значит 1) добавляем
				list[top_ptr] <= t_note;
				t_out_note <= max_note;
				out_gate <= 1;
				top_ptr <= top_ptr + 1'b1;
				note_on_state <= GETMAX;
			end
		end else if (note_on_state == GETMAX) begin
			state <= READY;
		end
	end else if (state==NOTE_OFF) begin
		if (note_off_state == ST_SEARCH) begin
			if (top_ptr==0) begin //случай, когда нот нет, но зачем-то хотят погасить - ничего не делаем
				state <= READY;
			end else begin
				addr <= 0; //инициируем addr и начинаем поиск
				max_note <= 0; 
				note_off_state <= IN_SEARCH;
			end
		end else if (note_off_state == IN_SEARCH) begin
			if (addr==top_ptr) begin
				note_off_state <= END_SEARCH;
				if (searched) top_ptr <= top_ptr - 1'b1;
			end else begin
				if (list[addr]==t_note) begin // если всетаки нашли - удаляем, перемещая последний на это место
					list[addr] <= list[top_ptr-1'b1];
					searched <= 1; // потом!  top_ptr <= top_ptr - 1'b1; //уменьшаем кол-во элементов в списке
				end
				
				if ((list[addr] > max_note)&&(list[addr]!=t_note)) max_note <= list[addr];
					
				addr <= addr + 1'b1;
			end
		end else if (note_off_state == END_SEARCH) begin
			t_out_note <= max_note;
			out_gate <= (top_ptr > 0);
			state <= READY;
		end
	end
end

endmodule
