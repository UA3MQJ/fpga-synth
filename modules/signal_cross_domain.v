module signal_cross_domain(
    input clkA,   // we actually don't need clkA in that example, but it is here for completeness as we'll need it in further examples
    input SignalIn_clkA,
    input clkB,
    output SignalOut_clkB
);

// We use a two-stages shift-register to synchronize SignalIn_clkA to the clkB clock domain
reg [1:0] SyncA_clkB  /* synthesis noprune */;
initial SyncA_clkB <= 2'b00;

always @(posedge clkB) SyncA_clkB[0] <= SignalIn_clkA;   // notice that we use clkB
always @(posedge clkB) SyncA_clkB[1] <= SyncA_clkB[0];   // notice that we use clkB

assign SignalOut_clkB = SyncA_clkB[1];  // new signal synchronized to (=ready to be used in) clkB domain
endmodule
