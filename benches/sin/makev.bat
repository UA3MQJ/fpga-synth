iverilog -o test ../../modules/sin.v testbench.v
vvp test
pause
