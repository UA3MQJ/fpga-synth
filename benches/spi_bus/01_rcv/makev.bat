iverilog -o test ../../../modules/spi_slave.v testbench.v
vvp test
pause
