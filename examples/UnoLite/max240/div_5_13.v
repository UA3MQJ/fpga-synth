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
// CREATED		"Wed Oct 12 19:44:20 2016"

module div_5_13(
	clk,
	div5,
	div13
);


input wire	clk;
output wire	div5;
output wire	div13;

wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;

assign	div5 = SYNTHESIZED_WIRE_5;
assign	div13 = SYNTHESIZED_WIRE_6;
assign	SYNTHESIZED_WIRE_9 = 0;




\7490 	b2v_inst(
	.SET9A(SYNTHESIZED_WIRE_9),
	.CLRA(SYNTHESIZED_WIRE_9),
	.SET9B(SYNTHESIZED_WIRE_9),
	.CLKB(clk),
	.CLKA(SYNTHESIZED_WIRE_3),
	.CLRB(SYNTHESIZED_WIRE_9),
	.QD(SYNTHESIZED_WIRE_5),
	.QA(SYNTHESIZED_WIRE_7)
	
	);



\7492 	b2v_inst2(
	.CLKB(SYNTHESIZED_WIRE_5),
	.CLRA(SYNTHESIZED_WIRE_6),
	.CLKA(SYNTHESIZED_WIRE_7),
	.CLRB(SYNTHESIZED_WIRE_8),
	.QB(SYNTHESIZED_WIRE_8),
	
	.QD(SYNTHESIZED_WIRE_3),
	.QA(SYNTHESIZED_WIRE_6));


endmodule
