one_tile_matmul:
    xor x10, x10, x10
    addi x10, x10, 0 # base address for weight matrix in ram
    xor x11, x11, x11
    addi x11, x11, 1024 # base address for input matrix in ram
    xor x12, x12, x12
    addi x12, x12, 1
    slli x12, x12, 15 # base address for output matrix in ram
    xor x13, x13, x13
    addi x13, x13, 8 # weight matrix's height
    xor x14, x14, x14
    addi x14, x14, 128 # weight matrix's width
    xor x15, x15, x15
    addi x15, x15, 128 # input matrix's height
    xor x16, x16, x16
    addi x16, x16, 16 # input matrix's width

    // Step1: Load weight matrix into CIM Module
    xor x17, x17, x17 # wh
    xor x19, x19, x19 
    add x19, x19, x10 # base addr for each row in weight matrix
    xor x20, x20, x20 # base addr for cim memory
load_weight_to_cim_memory:
    xor x18, x18, x18 # ww

inner_loop:
    lw x21, (x19)
    cimwr x21, x20
    addi x19, x19, 4
    addi x20, x20, 4

    addi x18, x18, 4
    // add nop?
    blt x18, x14, inner_loop
    addi x17, x17, 1
    // add nop?
    blt x17, x13, load_weight_to_cim_memory // line 28

    // Step2: Load inputs, calculate, and store results
    // assume input/weight matrix are stored tile by tile
    // assume input matrix is stored in transposed manner
    // assume output matrix is stored in normal order
    xor x17, x17, x17 # iw
    xor x22, x22, x22
    add x22, x22, x11 # base addr for input matrix
    xor x25, x25, x25 
    add x25, x25, x12 # base addr for output matrix
load_input_and_calculate:
    xor x18, x18, x18 # ih
    xor x23, x23, x23 # base addr for cim memory
calc_inner_loop:
    lw x24, (x22) 
    cimcomp x24, x23

    addi x18, x18, 8
    addi x22, x22, 4
    addi x23, x23, 8
    // add nop?
    blt x18, x15, calc_inner_loop

    // accumulate to previous results after this input column's calculation is finished
    xor x26, x26, x26 
    add x26, x26, x25 // output matrix's dst address
    xor x28, x28, x28 // cim register's id
    xor x30, x30, x30 
    add x30, x30, x16
    slli x30, x30, 2 // output address's bias value (in 1byte's granularity)

    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    add x26, x26, x30
    addi x28, x28, 1
    lw x27, (x26)
    cimregrd x28, x29
    add x27, x27, x29
    sw x27, (x26)

    // reset all output registers
    cimregreset

    addi x17, x17, 1
    addi x25, x25, 4
    // add nop?
    blt x17, x16, load_input_and_calculate // line 97
