module spi_slave #(parameter msg_len = 8) (CLK, SCK, MOSI, MISO, SSEL, MSG);
input wire CLK; //master project clock (50 mhz)

input wire SCK, SSEL, MOSI;
output wire MISO;
output wire [(msg_len-1):0] MSG;

assign MISO = 0;

// sync SCK to the FPGA clock using a 3-bits shift register
reg [2:0] SCKr; initial SCKr <= 3'd0;
always @(posedge CLK) SCKr <= {SCKr[1:0], SCK};
wire SCK_risingedge = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
//wire SCK_fallingedge = (SCKr[2:1]==2'b10);  // and falling edges

// same thing for SSEL
reg [2:0] SSELr; initial SSELr <= 3'd0;
always @(posedge CLK) SSELr <= {SSELr[1:0], SSEL};
wire SSEL_active = ~SSELr[1];  // SSEL is active low
//wire SSEL_startmessage = (SSELr[2:1]==2'b10);  // message starts at falling edge
//wire SSEL_endmessage = (SSELr[2:1]==2'b01);  // message stops at rising edge

// and for MOSI
reg [1:0] MOSIr; initial MOSIr <= 2'd0;
always @(posedge CLK) MOSIr <= {MOSIr[0], MOSI};
wire MOSI_data = MOSIr[1];

// we handle SPI in 8-bits format, so we need a 3 bits counter to count the bits as they come in
reg [$clog2(msg_len+1)-1:0] bitcnt; initial bitcnt <= {($clog2(msg_len+1)-1){1'b0}};

reg is_msg_received; initial is_msg_received <= 0; // high when a message has been received
reg [(msg_len-1):0] msg_data_received; initial msg_data_received <= {(msg_len){1'b0}};

always @(posedge CLK)
begin
  if(~SSEL_active)
    bitcnt <= 3'b000;
  else
  if(SCK_risingedge)
  begin
    bitcnt <= bitcnt + 3'b001;

    // implement a shift-left register (since we receive the data MSB first)
	//if - protect overflow data
	if (bitcnt<msg_len) msg_data_received <= {msg_data_received[6:0], MOSI_data};
  end
end

always @(posedge CLK) is_msg_received <= SSEL_active && SCK_risingedge && (bitcnt==3'b111);

assign MSG = msg_data_received;

endmodule
