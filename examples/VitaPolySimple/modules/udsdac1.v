`timescale 100 ps / 10 ps
`define MSBI 15

module udsdac1(Clk, DACin, DACout);
output DACout;
reg DACout;
input [`MSBI:0] DACin;
input Clk;

reg [`MSBI+2:0] DeltaAdder;
reg [`MSBI+2:0] SigmaAdder;
reg [`MSBI+2:0] SigmaLatch;
reg [`MSBI+2:0] DeltaB;

initial begin
        SigmaLatch = 1'b1 << (`MSBI+1);
        DACout = 1'b0;
end

always @(SigmaLatch) DeltaB = {SigmaLatch[`MSBI+2], SigmaLatch[`MSBI+2]} << (`MSBI+1);
always @(DACin or DeltaB) DeltaAdder = DACin + DeltaB;
always @(DeltaAdder or SigmaLatch) SigmaAdder = DeltaAdder + SigmaLatch;
always @(posedge Clk)
begin
        SigmaLatch <=  SigmaAdder;
        DACout <=  SigmaLatch[`MSBI+2];
end
endmodule