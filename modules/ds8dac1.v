/*module ds8dac1(clk, in_data, sout);
input clk;
input [7:0] in_data;
output reg sout;
reg [8:0] PWM_accumulator;

reg [7:0] PWM_add;

initial
begin
	PWM_accumulator <= 0;
	PWM_add <=0;
end

always @(posedge clk) begin
	PWM_accumulator <= PWM_accumulator[7:0] + PWM_add;
	PWM_add <= in_data;
end

always @(negedge clk) begin
	sout <= PWM_accumulator[8];
end

endmodule*/


// Delta-Sigma DAC
module ds8dac1(clk, DACin, DACout);
output DACout; // This is the average output that feeds low pass filter
reg DACout; // for optimum performance, ensure that this ff is in IOB
input [7:0] DACin; // DAC input 
input clk;
reg [9:0] DeltaAdder; // Output of Delta adder
reg [9:0] SigmaAdder; // Output of Sigma adder
reg [9:0] SigmaLatch; // Latches output of Sigma adder
reg [9:0] DeltaB; // B input of Delta adder

initial
begin
  DeltaAdder = 10'd0;
  SigmaAdder = 10'd0;
  SigmaLatch = 10'd0;
  DeltaB = 10'd0;
end

always @(SigmaLatch) DeltaB = {SigmaLatch[9], SigmaLatch[9]} << (8);
always @(DACin or DeltaB) DeltaAdder = DACin + DeltaB;
always @(DeltaAdder or SigmaLatch) SigmaAdder = DeltaAdder + SigmaLatch;

always @(posedge clk)
begin
  SigmaLatch <= SigmaAdder;
  DACout <=  SigmaLatch[9];
end

endmodule
