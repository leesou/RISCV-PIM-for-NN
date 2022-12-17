xor x11, x11, x11
xor x8, x8, x8
xor x9, x9, x9
// write to cim memory
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 4
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 4
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 4
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 116
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 4
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 124
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 4
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 124
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

addi x9, x9, 4
addi x8, x8, 4
lw x11, (x8)
cimwr x11, x9

// read from cim memory
xor x9, x9, x9
cimrd x11, x9
addi x9, x9, 4
cimrd x11, x9
addi x9, x9, 124
cimrd x11, x9
addi x9, x9, 4
cimrd x11, x9
addi x9, x9, 124
cimrd x11, x9
addi x9, x9, 4
cimrd x11, x9
addi x9, x9, 124
cimrd x11, x9
addi x9, x9, 4
cimrd x11, x9

// conduct in memory mvm