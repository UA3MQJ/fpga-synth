`timescale 1ns/1ns
module i2s_receive2 #
  (
   parameter width = 32
   )
  (
   input sck,
   input ws,
   input sd,
   output reg [width-1:0] data_left,
   output reg [width-1:0] data_right
   );

  reg wsd = 0;
  always @(posedge sck)
    wsd <= ws;

  reg wsdd;
  always @(posedge sck)
    wsdd <= wsd;

  wire wsp = wsd ^ wsdd;

  reg [$clog2(width+1)-1:0] counter;
  always @(negedge sck)
    if (wsp)
      counter <= 0;
    else if (counter < width)
      counter <= counter+1;

  reg [0:width-1] shift;
  always @(posedge sck)
    begin
      if (wsp)
	shift <= 0;
      if (counter < width)
	shift[counter] <= sd;
    end

  always @(posedge sck)
    if (wsd && wsp)
      data_left <= shift;

  always @(posedge sck)
    if (!wsd && wsp)
      data_right <= shift;

endmodule
