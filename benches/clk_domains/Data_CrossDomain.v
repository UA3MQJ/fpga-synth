module Data_CrossDomain(
    input clkA,
    input FlagIn_clkA, 
    input clkB,
    output FlagOut_clkB,
	input [7:0] dataA,
	output [7:0] dataB
);

// this changes level when the FlagIn_clkA is seen in clkA
reg FlagToggle_clkA;
initial FlagToggle_clkA <= 0;
always @(posedge clkA) FlagToggle_clkA <= FlagToggle_clkA ^ FlagIn_clkA;

reg [7:0] clkA_data;
initial clkA_data <= 8'd0;
always @(posedge clkA) begin
	if (FlagIn_clkA) begin
		clkA_data <= dataA;
	end
end

reg [7:0] clkB_data;
initial clkB_data <= 8'd0;

// which can then be sync-ed to clkB
reg [2:0] SyncA_clkB;
initial SyncA_clkB<=3'b000;
always @(posedge clkB) SyncA_clkB <= {SyncA_clkB[1:0], FlagToggle_clkA};

always @(posedge clkB) begin
	if (SyncA_clkB[1] ^ SyncA_clkB[0]) begin
		clkB_data <= clkA_data;
	end
end

assign dataB = clkB_data;

// and recreate the flag in clkB
assign FlagOut_clkB = (SyncA_clkB[2] ^ SyncA_clkB[1]);

endmodule
