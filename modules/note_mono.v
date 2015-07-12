module note_mono(clk, rst, note_on, note_off, note, out_note, out_gate);			   				   

//inputs outputs
input wire clk, rst, note_on, note_off;
input wire [6:0] note;
output wire [6:0] out_note;
output reg out_gate;

initial out_gate <= 0;

reg [6:0] t_out_note;
initial t_out_note <= 7'd0;

assign out_note = t_out_note;//(out_gate) ? t_out_note : 7'd0;

reg [127:0] keys;
initial keys <= 128'd0;
reg [6:0] bit_ptr;

//state list
parameter READY  = 1'd0;
parameter BUSY   = 1'd1;
reg state;
initial state <= READY;

always @(posedge clk) begin
	if (rst) begin
		out_gate <= 0;
		t_out_note <= 7'd0;
		keys <= 128'd0;
		state <= READY;
	end else if (state==READY) begin
		if (note_on) begin
			keys[note] <= 1;
			bit_ptr <= 7'd127;
			state <= BUSY;
		end else if (note_off) begin
			keys[note] <= 0;
			bit_ptr <= 7'd127;
			state <= BUSY;
		end
	end else if (state==BUSY) begin
		if (note_on||note_off) begin //если в процессе работы еще что-то пришло
			if (note_on) begin
				keys[note] <= 1;
			end else if (note_off) begin
				keys[note] <= 0;
			end
			bit_ptr <= 7'd127;
		end else if (bit_ptr==7'd0) begin //не нашли ни одной установленной ноты
			out_gate <= 0;
			state <= READY;
		end else if (keys[bit_ptr]== 1'b1) begin //нашли установленый бит - заканчиваем поиск
			out_gate <= 1;
			t_out_note <= bit_ptr;
			state <= READY;
		end else begin
			bit_ptr <= bit_ptr - 1'b1;
		end
	end
end

endmodule
