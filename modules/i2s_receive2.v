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
	
  initial data_left <= 0;
  initial data_right <= 0;

  reg wsd;
  initial wsd <= 1'b0;
  
  always @(posedge sck)
    wsd <= ws;

  reg wsdd;
  initial wsdd <= 1'b0;

  always @(posedge sck)
    wsdd <= wsd;

  wire wsp = wsd ^ wsdd;

  reg [$clog2(width+1)-1:0] counter;
  initial counter <= 0;
  
  always @(negedge sck)
    if (wsp)
      counter <= 0;
    else if (counter < width)
      counter <= counter+1;

  reg [0:width-1] shift;
  initial shift <= 0;
  
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
