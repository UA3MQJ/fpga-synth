module frqdivmod(clk, s_out);
parameter DIV=2;
// calculated parameters
parameter WITH = ($clog2(DIV)>0) ? $clog2(DIV) : 1;

input wire clk;
output wire s_out;

reg clk_n;

reg [(WITH-1):0] pos_cnt;
reg [(WITH-1):0] neg_cnt;

initial begin
	clk_n <= 1'b0;
	pos_cnt <= {(WITH){1'b0}};
	neg_cnt <= {(WITH){1'b0}};
end

assign s_out = (DIV==1) ? clk : clk_n;

always @ ( posedge clk ) begin
	pos_cnt <= (pos_cnt + 1'b1) % DIV;
end

always @ (negedge clk) begin
	neg_cnt <= (neg_cnt + 1'b1) % DIV;
end

always @(clk) begin
	if ((DIV%2) == 1'b0) begin
		clk_n <= ( pos_cnt >= (DIV/2)) ? 1'b1 : 1'b0;
	end else begin
		clk_n <= (( pos_cnt > (DIV/2)) || ( neg_cnt > (DIV/2))) ? 1'b1 : 1'b0;
	end
end	
	
endmodule
