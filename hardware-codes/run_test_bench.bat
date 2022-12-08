rm wave
iverilog -o wave %1
vvp -n wave -lxt2
gtkwave wave.vcd