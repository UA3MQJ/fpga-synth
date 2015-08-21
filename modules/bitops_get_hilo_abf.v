module bitops_get_hilo_abf(a,r,out,out_r);
input wire a,r;
output wire out, out_r;

assign  out = (~r)&&a; //out = (r==0) ? a : 0;
assign  out_r = r||a;//(r==1)||(a==1);

endmodule
