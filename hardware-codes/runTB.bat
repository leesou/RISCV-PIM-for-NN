rm wave
iverilog -o wave tb_mem.v
vvp -n wave -lxt2
gtkwave wave.vcd