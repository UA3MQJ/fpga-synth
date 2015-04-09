iverilog -o test ../../modules/note_pitch2dds.v ../../modules/note2dds.v testbench.v
vvp test
pause
