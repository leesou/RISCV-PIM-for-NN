rm wave
rm wave.vcd
rm *.output
iverilog -o wave $1
vvp -n wave -lxt2
gtkwave wave.vcd