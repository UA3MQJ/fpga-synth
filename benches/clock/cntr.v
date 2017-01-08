// counter
module cntr #(parameter max=9) (clk, en, res, out, cy);

input wire clk, res, en;
output reg cy; initial cy <= 0;
output reg [$clog2(max+1)-1:0] out; initial out <= {($clog2(max+1)-1){1'b0}};

wire ovr = (out>max);
always @(posedge clk) begin
  if (ovr) begin 
    out <= {($clog2(max+1)-1){1'b0}};
	cy  <= 1;
  end else if (res) begin 
    out <= {($clog2(max+1)-1){1'b0}};
	cy  <= 0;
  end else begin
    out <= (en) ? out + 1'b1 : out;
	cy  <= 0;
  end
end

endmodule

