// Copyright (C) 1991-2011 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 32-bit"
// VERSION		"Version 11.1 Build 173 11/01/2011 SJ Full Version"
// CREATED		"Wed Oct 12 19:43:24 2016"

module div_23(
	clk,
	div23
);


input wire	clk;
output wire	div23;

wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;

assign	div23 = SYNTHESIZED_WIRE_11;
assign	SYNTHESIZED_WIRE_12 = 0;
assign	SYNTHESIZED_WIRE_14 = 0;




\7490 	b2v_inst(
	.SET9A(SYNTHESIZED_WIRE_11),
	.CLRA(SYNTHESIZED_WIRE_12),
	.SET9B(SYNTHESIZED_WIRE_13),
	.CLKB(SYNTHESIZED_WIRE_3),
	.CLKA(clk),
	.CLRB(SYNTHESIZED_WIRE_12),
	.QD(SYNTHESIZED_WIRE_9),
	.QA(SYNTHESIZED_WIRE_3),
	.QB(SYNTHESIZED_WIRE_13)
	);




\7490 	b2v_inst2(
	.SET9A(SYNTHESIZED_WIRE_13),
	.CLRA(SYNTHESIZED_WIRE_14),
	.SET9B(SYNTHESIZED_WIRE_11),
	.CLKB(SYNTHESIZED_WIRE_8),
	.CLKA(SYNTHESIZED_WIRE_9),
	.CLRB(SYNTHESIZED_WIRE_14),
	
	.QA(SYNTHESIZED_WIRE_8),
	.QB(SYNTHESIZED_WIRE_11)
	);


endmodule
