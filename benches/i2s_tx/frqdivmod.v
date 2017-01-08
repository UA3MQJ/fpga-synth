module frqdivmod(clk, s_out);
parameter DIV=2;
// calculated parameters
parameter WITH = ($clog2(DIV+1)>0) ? $clog2(DIV+1) : 1;

input wire clk;
output wire s_out;

reg clk_n; 

reg [(WITH-1):0] pos_cnt; 
reg [(WITH-1):0] neg_cnt; 

wire [(WITH-1):0] div_value = DIV[(WITH-1):0];

//div2 - 0  -- 1
//div4 - 1     2
//div6 - 2     3
//div8 - 3     4
initial begin
	clk_n <= 1'b0;
	pos_cnt <= {(WITH){1'b0}} + (DIV/2 - 1);
	neg_cnt <= {(WITH){1'b0}};
end

assign s_out = (DIV==1) ? clk : clk_n;

always @ (posedge clk) begin
	pos_cnt <= (pos_cnt + 1'b1) % div_value;
end

always @ (negedge clk) begin
	neg_cnt <= (neg_cnt + 1'b1) % div_value;
end

always @(clk, pos_cnt, neg_cnt) begin //pos_cnt in sens list addd for resolve warning "variable is read inside the Always Construct but isn't in the Always Construct's Event Control"
	if ((DIV%2) == 1'b0) begin
		clk_n <= ( pos_cnt >= (DIV/2)) ? 1'b1 : 1'b0;
	end else begin
		clk_n <= (( pos_cnt > (DIV/2)) || ( neg_cnt > (DIV/2))) ? 1'b1 : 1'b0;
	end
end
	
endmodule
