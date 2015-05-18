module powerup_reset(key, clk, rst);
parameter TICK = 4'd15; // tick's delay 0..15
		
input wire key;
input wire clk;
output reg rst;
		
reg [3:0] tick_timer;

initial begin
	rst <= 1;
	tick_timer <= TICK;
end
	
always @(posedge clk) begin
	if (key) begin
		tick_timer <= TICK;
		rst <= 1;
	end else begin
		if (tick_timer==4'd0) begin
			rst <= 0;
		end else begin
			tick_timer <= tick_timer - 1'b1;
		end
	end
end

endmodule
