module Flag_CrossDomain(
    input clkA,
    input FlagIn_clkA, 
    input clkB,
    output FlagOut_clkB
);

// this changes level when the FlagIn_clkA is seen in clkA
reg FlagToggle_clkA /* synthesis noprune */;
initial FlagToggle_clkA <= 0;
always @(posedge clkA) FlagToggle_clkA <= FlagToggle_clkA ^ FlagIn_clkA;

// which can then be sync-ed to clkB
reg [2:0] SyncA_clkB /* synthesis noprune */;
initial SyncA_clkB<=3'b000;
always @(posedge clkB) SyncA_clkB <= {SyncA_clkB[1:0], FlagToggle_clkA};

// and recreate the flag in clkB
assign FlagOut_clkB = (SyncA_clkB[2] ^ SyncA_clkB[1]);
endmodule
