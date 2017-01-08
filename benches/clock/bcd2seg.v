
//bin to 7seg
module bcd2seg(sin, sout);
input wire [3:0] sin;
output wire [6:0] sout;

assign sout = (sin==4'h0) ? 7'b0111111 :
              (sin==4'h1) ? 7'b0000110 :
              (sin==4'h2) ? 7'b1011011 :
              (sin==4'h3) ? 7'b1001111 :
              (sin==4'h4) ? 7'b1100110 :
              (sin==4'h5) ? 7'b1101101 :
              (sin==4'h6) ? 7'b1111101 :
              (sin==4'h7) ? 7'b0000111 :
              (sin==4'h8) ? 7'b1111111 :
              (sin==4'h9) ? 7'b1101111 : 7'b0000000;

endmodule

