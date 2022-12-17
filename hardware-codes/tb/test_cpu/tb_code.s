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
xor x9, x9, x9
xor x8, x8, x8
addi x9, x9, 40
lw x11, (x9)
cimcomp x11, x8
addi x9, x9, 4
lw x11, (x9)
cimcomp x11, x8
addi x8, x8, 8
addi x9, x9, 4
lw x11, (x9)
cimcomp x11, x8
addi x9, x9, 4
lw x11, (x9)
cimcomp x11, x8

// read cim_output registers
xor x9, x9, x9
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9

// reset cim_output registers
cimregreset

// read cim_output registers again to check reset
xor x9, x9, x9
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9
addi x9, x9, 1
cimregrd x11, x9