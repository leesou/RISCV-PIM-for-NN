rm wave
iverilog -o wave tb_cpu.v
vvp -n wave -lxt2
gtkwave wave