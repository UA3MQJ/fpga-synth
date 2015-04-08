`define VectorSize 256   // длина вектора - 8 элементов
//`define ElementSize 1  // разрядность каждого элемента вектора

module mov(clk, in, out);

input clk;
input wire [(`VectorSize-1):0] in;
output reg [(`VectorSize-1):0] out;

wire [7:0] random8bit;
rnd8 rnd_gen(clk, random8bit[7:0]);
wire [15:0] randomValue_t = random8bit * `VectorSize; 
wire [7:0]  randomValue = randomValue_t[15:15-7];

// вектор
//reg [(`ElementSize-1):0] ADDER_tbl [`VectorSize:0];

initial
begin
  out <= 0;
end

always @ (posedge clk) begin
  out[randomValue] <= in[randomValue];
end
	
endmodule
