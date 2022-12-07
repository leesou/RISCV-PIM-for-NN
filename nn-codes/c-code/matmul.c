#define CIM_MEM_SIZE 1024
#define TILE_HEIGHT 8
#define TILE_WIDTH 128

#define WEIGHT_GRANULARITY 4 // 8bits weight
#define CIM_INPUT_WIDTH 8 // 4bits input

void matmul(
    void* weight_matrix, void* input_matrix, void* output_matrix, void* CIM_memory,
    int weight_height, int weight_width, int input_height, int input_width
)
{
    // weight stationary
    for(int wh_out=0; wh_out<weight_height; wh_out+=TILE_HEIGHT)
    {
        for(int ww_out=0; ww_out<weight_width; ww_out+=TILE_WIDTH) // shared by both weight matrx and input matrix
        {

            // Step1: Load weights to CIM memory
            for(int wh_in=0; wh_in<TILE_HEIGHT; wh_in+=1)
            {
                for(int ww_in=0; ww_in<TILE_WIDTH/WEIGHT_GRANULARITY; ww_in+=1)
                {
                    int height = wh_out+wh_in;
                    int width = ww_out+ww_in;
                    // load weight value to CPU
                    unsigned weights = *(((unsigned*)weight_matrix) + height*weight_width/WEIGHT_GRANULARITY + width);
                    // store this value to CIM module, CIM's start address is just (height*TILE_WIDTH + ww_in*WEIGHT_GRANULARITY)
                    int CIM_start_address = height*TILE_WIDTH + ww_in*WEIGHT_GRANULARITY;
                    asm volatile( "nop" );    
                }
            }

            // Step2: Load inputs and compute recurrently
            for(int iw=0; iw<input_width; iw+=1)
            {

                // since the input of CIM is limited, we need to tile again
                for(int ih=ww_out; ih<ww_out+TILE_WIDTH; ih+=CIM_INPUT_WIDTH)
                {
                    // Load CIM inputs
                    unsigned inputs = *(((unsigned*)input_matrix) + ih*input_width/CIM_INPUT_WIDTH + iw);
                    // drive the CIM module
                    asm volatile( "nop" );
                }

                // Load output partial sum
                unsigned output0 = *((((int*)output_matrix) + wh_out*input_width + iw));
                unsigned output1 = *((((int*)output_matrix) + (wh_out+1)*input_width + iw));
                unsigned output2 = *((((int*)output_matrix) + (wh_out+2)*input_width + iw));
                unsigned output3 = *((((int*)output_matrix) + (wh_out+3)*input_width + iw));
                unsigned output4 = *((((int*)output_matrix) + (wh_out+4)*input_width + iw));
                unsigned output5 = *((((int*)output_matrix) + (wh_out+5)*input_width + iw));
                unsigned output6 = *((((int*)output_matrix) + (wh_out+6)*input_width + iw));
                unsigned output7 = *((((int*)output_matrix) + (wh_out+7)*input_width + iw));

                // Read out CIM results
                unsigned ps0, ps1, ps2, ps3, ps4, ps5, ps6, ps7 = 0;
                asm volatile( "nop" );
                asm volatile( "nop" );
                asm volatile( "nop" );
                asm volatile( "nop" );
                asm volatile( "nop" );
                asm volatile( "nop" );
                asm volatile( "nop" );
                asm volatile( "nop" );

                // add to previous results
                output0 += ps0;
                output1 += ps1;
                output2 += ps2;
                output3 += ps3;
                output4 += ps4;
                output5 += ps5;
                output6 += ps6;
                output7 += ps7;

                // Write back outputs
                *((((int*)output_matrix) + wh_out*input_width + iw)) = output0;
                *((((int*)output_matrix) + (wh_out+1)*input_width + iw)) = output1;
                *((((int*)output_matrix) + (wh_out+2)*input_width + iw)) = output2;
                *((((int*)output_matrix) + (wh_out+3)*input_width + iw)) = output3;
                *((((int*)output_matrix) + (wh_out+4)*input_width + iw)) = output4;
                *((((int*)output_matrix) + (wh_out+5)*input_width + iw)) = output5;
                *((((int*)output_matrix) + (wh_out+6)*input_width + iw)) = output6;
                *((((int*)output_matrix) + (wh_out+7)*input_width + iw)) = output7;

            }

        }
    }
}