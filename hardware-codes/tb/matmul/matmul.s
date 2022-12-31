matmul:
    # x10-x16 are used to transfer parameters
    xor x10, x10, x10
    addi x10, x10, 0 # base address for weight matrix in ram
    xor x11, x11, x11
    addi x11, x11, 1024
    slli x11, x11, 2
    addi x11, x11, 1024
    addi x11, x11, 1024 # base address for input matrix in ram
    xor x12, x12, x12
    addi x12, x12, 1
    slli x12, x12, 15
    xor x13, x13, x13
    addi x13, x13, 1
    slli x13, x13, 13
    add x12, x12, x13
    addi x12, x12, 1024
    addi x12, x12, 1024
    addi x12, x12, 768 # base address for output matrix in ram
    xor x13, x13, x13
    addi x13, x13, 16 # weight matrix's height
    xor x14, x14, x14
    addi x14, x14, 384 # weight matrix's width
    xor x15, x15, x15
    addi x15, x15, 384 # input matrix's height
    xor x16, x16, x16
    addi x16, x16, 196 # input matrix's width # line 25

    xor x7, x7, x7
    addi x7, x7, 8 # weight tile height
    xor x9, x9, x9
    addi x9, x9, 128 # weight tile width # line 29

    # execution loop begins
    xor x5, x5, x5 # wh_out
    xor x19, x19, x19 
    add x19, x19, x10 # base addr for each tile in weight matrix
    xor x31, x31, x31
    add x31, x31, x12 # base addr for output tile
tile_outer_loop:
    xor x6, x6, x6 # ww_out
    xor x22, x22, x22
    add x22, x22, x11 # base addr for input matrix
tile_inner_loop: # for tiles in the same rows


    # Step1: Load weight matrix into CIM Module
    xor x17, x17, x17 # wh_in
    xor x20, x20, x20 # base addr for cim memory
load_weight_to_cim_memory:
    xor x18, x18, x18 # ww_in
load_inner_loop:
    lw x21, (x19)
    cimwr x21, x20
    # update addresses
    addi x19, x19, 4
    addi x20, x20, 4
    # update loop variants
    addi x18, x18, 4
    blt x18, x9, load_inner_loop
    addi x17, x17, 1
    blt x17, x7, load_weight_to_cim_memory # line 48

    # Step2: Load inputs, calculate, and store results
    # assume input/weight matrix are stored tile by tile
    # assume input matrix is stored in transposed manner
    # assume output matrix is stored in normal order
    xor x17, x17, x17 # iw
    xor x25, x25, x25 
    add x25, x25, x31 # base addr for current output column
load_input_and_calculate:
    xor x18, x18, x18 # ih
    xor x23, x23, x23 # base addr for cim memory
calc_inner_loop:
    lw x24, (x22) 
    cimcomp x24, x23
    # update addresses
    addi x22, x22, 4
    addi x23, x23, 8
    # update loop variants
    addi x18, x18, 8
    blt x18, x9, calc_inner_loop

    # accumulate to previous results after this input column's calculation is finished
    xor x26, x26, x26 
    add x26, x26, x25 # output matrix's dst address
    xor x28, x28, x28 # cim register's id
    xor x30, x30, x30 
    add x30, x30, x16
    slli x30, x30, 2 # output address's bias value (in 1byte's granularity)

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

    # reset all output registers
    cimregreset

    addi x17, x17, 1
    addi x25, x25, 4
    # add nop?
    blt x17, x16, load_input_and_calculate # line 115

update_outer_loop:
    add x6, x6, x9
    blt x6, x14, tile_inner_loop
    
    slli x1, x16, 3
    slli x1, x1, 2 // each element occupies 4 bytes
    add x31, x31, x1 // update output tile's addr
    add x5, x5, x7
    blt x5, x13, tile_outer_loop # line 122