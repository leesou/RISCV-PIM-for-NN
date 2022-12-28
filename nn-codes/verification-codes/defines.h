#ifndef DEFINES_H
#define DEFINES_H

#define TILE_HEIGHT 8
#define TILE_WIDTH 128

#define CIM_INPUT_SIZE 8

#define ADC_PRECISION 6
#define RAM_PRECISION 32
#define INPUT_PRECISION 4 // bit
#define WEIGHT_PRECISION 8 // bit

#define ONE_TILE_MATMUL
//#define FULL_MATMUL

#define RAM_FILE_NAME "tb_ram.hex"
#define INPUT_TENSOR_FILE_NAME "input_tensor.txt"
#define WEIGHT_TENSOR_FILE_NAME "weight_tensor.txt"
#define INPUT_2D_MATRIX_FILE_NAME "input_matrix_2d.txt"
#define WEIGHT_2D_MATRIX_FILE_NAME "weight_matrix_2d.txt"
#define SOFTWARE_RESULT_FILE_NAME "software_result.txt"

#ifdef ONE_TILE_MATMUL // for one-tile matmul test

    #define INPUT_CHANNEL 3
    #define INPUT_HEIGHT 3
    #define INPUT_WIDTH 3

    #define OUTPUT_CHANNEL 2
    #define KERNEL_HEIGHT 2
    #define KERNEL_WIDTH 2

    #define PADDING 1
    #define STRIDE_HEIGHT 1
    #define STRIDE_WIDTH 1

    #define WEIGHT_MATRIX_ADDR 0
    #define INPUT_MATRIX_ADDR 1024 // index by byte

    #define ROOT_DIR "../../test_data/one_tile_matmul/"

#elif defined(FULL_MATMUL)


#endif


#endif // DEFINES_H