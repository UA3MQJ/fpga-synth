module ModuleTester(clk, clken, reset_n, in_data, in_valid, out_ready, in_error, out_data, in_ready, out_valid, out_error);

	input		clk;
	input		clken;
	input		reset_n;
	input		in_data;
	input		in_valid;
	input		out_ready;
	input	[1:0]	in_error;
	output	[15:0]	out_data;
	output		in_ready;
	output		out_valid;
	output	[1:0]	out_error;

  cic1 cic1_inst (
      .clk(clk),
      .clken(1),
      .reset_n(1),
      .in_ready(in_ready),
      .in_valid(1),
      .in_data(in_data),
      .out_data(out_data),
      .in_error(2'b00),
      .out_error(out_error),
      .out_ready(1),
      .out_valid(out_valid)
      );

endmodule
