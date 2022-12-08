rm wave
rm wave.vcd
iverilog -o wave $1
vvp -n wave -lxt2
gtkwave wave.vcd