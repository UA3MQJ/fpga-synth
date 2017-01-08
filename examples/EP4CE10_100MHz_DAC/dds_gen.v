module dds_gen(clk, key1, key2, da_clk, da_db);
input wire clk;
input wire key1;
input wire key2;
output wire da_clk;
output wire [7:0] da_db;

wire clk100M;
pll100M gen_100MHz(.inclk0(clk),
                   .c0(clk100M));

reg [31:0] dds_accum; initial dds_accum <= 32'd0;
reg [31:0] dds_adder; initial dds_adder <= 32'd179272; // 440 Hz

reg [31:0] delay_cnt; initial delay_cnt <= 32'd0;

//assign clk100M = clk;

//трех битный буфер
reg [2:0] gate_buff1;
reg [2:0] gate_buff2;

always @ (posedge clk100M) begin
  gate_buff1 <= {gate_buff1[1:0],~key1}; 
  gate_buff2 <= {gate_buff2[1:0],~key2}; 
end

//буфферизированное значение
assign GATE1_D = (gate_buff1 == 3'b111);
assign GATE2_D = (gate_buff2 == 3'b111);


always @(posedge clk100M) begin
	dds_accum <= dds_accum + dds_adder;
	delay_cnt <= delay_cnt + 1'b1;

	if(delay_cnt==32'd0) begin
		delay_cnt <= 32'd1000000;
		
		dds_adder <= (GATE1_D) ? dds_adder + 32'd100 :
						 (GATE2_D) ? dds_adder - 32'd100 : dds_adder;
	end else begin
		delay_cnt <= delay_cnt - 1'b1;
	end

end
  

assign da_db = dds_accum[31:31-7]; //high bits of dds accum
assign da_clk = clk100M;

endmodule
