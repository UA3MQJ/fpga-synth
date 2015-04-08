module frq1divmod1(clk, val, cout);

input wire clk;
input wire [24:0] val;
output reg cout;

reg [24:0] cnt;
reg [24:0] saved_val;

initial begin
	cnt = 0;
	saved_val = val;
end

always @ (posedge clk) begin
    if(cnt==saved_val) begin
       cnt <= 0;
		 cout <= ~cout;
		 saved_val = val;
    end else
       cnt <= cnt + 1'b1;
end 

endmodule
