module fifo(in_data, in_d_rdy, clk, out_data, out_d_rdy, rdy2rcv);
parameter WIDTH=8;
					   
parameter BUFF_LEN=16;
parameter BUFF_LENm=BUFF_LEN - 1;

parameter BUFF_LEN_WIDTH_bits  = (BUFF_LENm[7:7]==1'b1) ? 8 : 
					   (BUFF_LENm[6:6]==1'b1) ? 7 :
					   (BUFF_LENm[5:5]==1'b1) ? 6 :
					   (BUFF_LENm[4:4]==1'b1) ? 5 :
					   (BUFF_LENm[3:3]==1'b1) ? 4 :
					   (BUFF_LENm[2:2]==1'b1) ? 3 :
					   (BUFF_LENm[1:1]==1'b1) ? 2 :
					   (BUFF_LENm[0:0]==1'b1) ? 1 : 0;

input wire [(WIDTH-1):0] in_data;
input wire in_d_rdy, clk, rdy2rcv;
output wire [(WIDTH-1):0] out_data;
output wire out_d_rdy;

//fifo

reg [(BUFF_LEN_WIDTH_bits-1):0] fifo_buff_wptr;
initial fifo_buff_wptr <= {BUFF_LEN_WIDTH_bits {1'b0}};
reg [(BUFF_LEN_WIDTH_bits-1):0] fifo_buff_sptr;
initial fifo_buff_sptr <= {BUFF_LEN_WIDTH_bits {1'b0}};
reg [(BUFF_LEN_WIDTH_bits-1):0] fifo_buff_cnt;
initial fifo_buff_cnt <= {BUFF_LEN_WIDTH_bits {1'b0}};
reg [(WIDTH-1):0] fifo_buff [0:(BUFF_LEN-1)];

integer i;
initial begin
	for(i=0;i<BUFF_LEN;i=i+1) begin 
		fifo_buff[i] <= {WIDTH {1'b0}};
	end
end

assign out_d_rdy = (fifo_buff_cnt>0)&&rdy2rcv;
assign out_data = (out_d_rdy) ? fifo_buff[fifo_buff_sptr] : {WIDTH {1'b0}};
//assign out_data = fifo_buff[fifo_buff_sptr];

always @ (posedge clk) begin
	if (in_d_rdy==1'b1) begin //in_d_rdy - store
		fifo_buff[fifo_buff_wptr] <= in_data;
		fifo_buff_wptr <= fifo_buff_wptr + 1'b1;
		if ((fifo_buff_cnt!={BUFF_LEN_WIDTH_bits {1'b0}})&&(rdy2rcv==1'b1)) begin
			fifo_buff_sptr <= fifo_buff_sptr + 1'b1;
			fifo_buff_cnt <= fifo_buff_cnt; 
		end else begin
			fifo_buff_cnt <= fifo_buff_cnt + 1'b1;
		end
	end else begin // restore data only when not write data
		if ((fifo_buff_cnt!={BUFF_LEN_WIDTH_bits {1'b0}})&&(rdy2rcv==1'b1)) begin
			fifo_buff_sptr <= fifo_buff_sptr + 1'b1;
			fifo_buff_cnt <= fifo_buff_cnt - 1'b1;
		end
	end

end
	
endmodule
