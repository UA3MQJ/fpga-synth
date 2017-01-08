module sin(clk, xx);

	parameter N= 4;//5;
	parameter R= 19;
	parameter Rm= R-1;
	
input wire clk;
output wire signed [7:0] xx;

  reg signed [R:0] x,y;
  
assign xx = x[R:R-7];

initial 
begin
	y <= (1<<<Rm)-1;
	x <= 0;
end

always @(posedge clk) begin
	if ( y[R:Rm]== 2'b01 ) begin
		y <= (1<<<Rm)-1;
		x <= 0;
	end	else begin
		x <= ( x + (y>>>N) - (x>>>(2*N+1)) );
		y <= ( y - (x>>>N) - (y>>>(2*N+1)) );
	end
end


endmodule
