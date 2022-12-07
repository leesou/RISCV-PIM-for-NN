matmul:
    xor x10, x10, x10
    addi x10, x10, 0 # base addr for weight matrix

    xor x14, x14, x14
    addi x14, x14, 8 # weight matrix's height
    xor x15, x15, x15
    addi x15, x15, 32 # weight matrix's width, divided by 4 (ram's granularity is 4bytes, weight 1s 1 byte)
    
    xor x17, x17, x17 # wh_out
main_loop:
    xor x18, x18, x18 # ww_out

weight_load:
    xor x19, x19, x19 # wh_in

weight_load_inner:
    add x21, x17, x19 # height = wh_out+wh_in
    xor x20, x20, x20 # ww_in

load_execution:
    add x22, x18, x20 # width = ww_out+ww_in
    mul x23, x21, x15 # height * (scaled_width)
    add x23, x23, x10 # + base address
    add x23, x23, x22
    ld x23, (x23) # load 32bits weight data
    muli x24, x21, 128
    muli x25, x20, 4
    add x24, x24, x25 # CIM's base addr
    cimwr x24, x25 # store to 

    addi x20, x20, 1
    xor x22, x22, x22
    addi x22, x22, 32 # tile_width/weight_granularity
    blt x20, x22, load_execution

    addi x19, x19, 1
    xor x22, x22, x22
    addi x22, x22, 8 # tile_height
    blt x19, x22, weight_load_inner

    addi x18, x18, 32 # tile width is 128, need to be divided by pack num (4)
    blt x18, x15, weight_load

    addi x17, x17, 8 # tile height is 8
    blt x17, x14, main_loop


