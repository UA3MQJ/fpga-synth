module lin2exp(in_data, out_data);

input wire [6:0] in_data;
output wire [31:0] out_data;

//wire [31:0] line1 = 7540 - (in_data * 364);
wire [31:0] line1 = 7540 - ({in_data,8'b0}+{in_data,6'b0}+{in_data,5'b0}+{in_data,3'b0}+{in_data,2'b0});

//wire [31:0] line2 = 6637 - (in_data * 235);
wire [31:0] line2 = 6637 - ({in_data,8'b0}-{in_data,5'b0}+{in_data,3'b0}+{in_data,1'b0});

//wire [31:0] line3 = 5317 - (in_data * 147);
wire [31:0] line3 = 5317 - ({in_data,7'b0}+{in_data,4'b0}+{in_data,1'b0}+in_data);

//wire [31:0] line4 = 4006 - (in_data * 90);
wire [31:0] line4 = 4006 - ({in_data,6'b0}+{in_data,4'b0}+{in_data,3'b0}+{in_data,2'b0});

//wire [31:0] line5 = 2983 - (in_data * 57);
wire [31:0] line5 = 2983 - ({in_data,6'b0}-{in_data,3'b0}+in_data);

//wire [31:0] line6 = 2008 - (in_data * 32);
wire [31:0] line6 = 2008 - ({in_data,5'b0});

//wire [31:0] line7 = 1039 - (in_data * 13);
wire [31:0] line7 = 1039 - ({in_data,3'b0}+{in_data,2'b0}+in_data);

//wire [31:0] line8 = 207 - (in_data * 2);
//real 206,8 - (in_data * 1,6)
wire [31:0] line8 = (16'hCECC - ( {in_data,8'b0} + {in_data,7'b0} + {in_data,4'b0} + {in_data,3'b0} + in_data ) ) >> 8;



assign out_data = (in_data <  8) ?  line1 :
                  (in_data < 16) ?  line2 :
                  (in_data < 24) ?  line3 :
                  (in_data < 32) ?  line4 :
                  (in_data < 40) ?  line5 :
                  (in_data < 52) ?  line6 :
                  (in_data < 74) ?  line7 :
                                    line8;
									 
endmodule

/*


; ACC = ACC * 364
; Add input * 256 to accumulator   <<  8    {in_data,8'b0}
; Add input * 64 to accumulator    <<  6    {in_data,6'b0}
; Add input * 32 to accumulator    <<  5    {in_data,5'b0}
; Add input * 8 to accumulator     <<  3    {in_data,3'b0}
; Add input * 4 to accumulator     <<  2    {in_data,2'b0}

; ACC = ACC * 235
; Add input * 256 to accumulator          <<  8    {in_data,8'b0}
; Substract input * 32 from accumulator   <<  5    {in_data,5'b0}
; Add input * 8 to accumulator            <<  3    {in_data,3'b0}
; Add input * 2 to accumulator            <<  1    {in_data,1'b0}

; ACC = ACC * 147
; Add input * 128 to accumulator   <<  7    {in_data,7'b0}
; Add input * 16 to accumulator    <<  4    {in_data,4'b0}
; Add input * 2 to accumulator     <<  1    {in_data,1'b0}
; Add input * 1 to accumulator               in_data

; ACC = ACC * 90
; Add input * 64 to accumulator    <<  6    {in_data,6'b0}
; Add input * 16 to accumulator    <<  4    {in_data,4'b0}
; Add input * 8 to accumulator     <<  3    {in_data,3'b0}
; Add input * 2 to accumulator     <<  2    {in_data,2'b0}

; ACC = ACC * 57
; Add input * 64 to accumulator         <<  6    {in_data,6'b0}
; Substract input * 8 from accumulator  <<  3    {in_data,3'b0}
; Add input * 1 to accumulator                    in_data

; ACC = ACC * 13
; Add input * 8 to accumulator     <<  3    {in_data,3'b0}
; Add input * 4 to accumulator     <<  2    {in_data,2'b0}
; Add input * 1 to accumulator               in_data


; ACC = ACC * 1.6    � ���� ������ 01 99h
������� ������ �������������� �� 8 ��� �����
; Add input * 1 to accumulator     << 8 
; Add input / 2 to accumulator     << 8 >> 1  � ����� >> 7
; Add input / 16 to accumulator    << 8 >> 4  � ����� >> 4
; Add input / 32 to accumulator    << 8 >> 5  � ����� >> 3
; Add input / 256 to accumulator   << 8 >> 8  � ����� >> 0
*/
