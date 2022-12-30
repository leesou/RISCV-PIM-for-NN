#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <string>
#include "defines.h"
using namespace std;


vector<vector<vector<int> > > input_tensor; // channel---height---width
vector<vector<vector<vector<int> > > > weight_tensor; // output_channel---input_channel---height---width

vector<vector<int> > input_2d_matrix;
vector<vector<int> > weight_2d_matrix;
vector<vector<int> > output_2d_matrix;


void read_tensors()
{
    // read input tensor
    string input_tensor_file = string(ROOT_DIR)+string(INPUT_TENSOR_FILE_NAME);
    ifstream input_tensor_if(input_tensor_file);
    // init tensor
    input_tensor.resize(INPUT_CHANNEL);
    for(int i=0; i<INPUT_CHANNEL; ++i)
    {
        input_tensor[i].resize(INPUT_HEIGHT+2*PADDING);
        for(int j=0; j<INPUT_HEIGHT+2*PADDING; ++j)
        {
            input_tensor[i][j].resize(INPUT_WIDTH+2*PADDING);
            for(int k=0; k<INPUT_WIDTH+2*PADDING; ++k)
            {
                input_tensor_if >> input_tensor[i][j][k];
            }
        }
    }

    // read weight tensor
    string weight_tensor_file = string(ROOT_DIR)+string(WEIGHT_TENSOR_FILE_NAME);
    ifstream weight_tensor_if(weight_tensor_file);
    // init tensor
    weight_tensor.resize(OUTPUT_CHANNEL);
    for(int i=0; i<OUTPUT_CHANNEL; ++i)
    {
        weight_tensor[i].resize(INPUT_CHANNEL);
        for(int j=0; j<INPUT_CHANNEL; ++j)
        {
            weight_tensor[i][j].resize(KERNEL_HEIGHT);
            for(int k=0; k<KERNEL_HEIGHT; ++k)
            {
                weight_tensor[i][j][k].resize(KERNEL_WIDTH);
                for(int l=0; l<KERNEL_WIDTH; ++l)
                {
                    weight_tensor_if >> weight_tensor[i][j][k][l];
                }
            }
        }
    }
}


void flat_conv_to_matmul()
{
    // flat weight tensor
    int weight_matrix_2d_height = OUTPUT_CHANNEL;
    int weight_matrix_2d_width = INPUT_CHANNEL*KERNEL_HEIGHT*KERNEL_WIDTH;
    weight_2d_matrix.resize(weight_matrix_2d_height);
    for(int i=0; i<weight_matrix_2d_height; ++i)
    {
        weight_2d_matrix[i].resize(weight_matrix_2d_width);
        int width_pos = 0;
        for(int j=0; j<INPUT_CHANNEL; ++j)
        {
            for(int k=0; k<KERNEL_HEIGHT; ++k)
            {
                for(int l=0; l<KERNEL_WIDTH; ++l)
                {
                    weight_2d_matrix[i][width_pos] = weight_tensor[i][j][k][l];
                    width_pos++;
                }
            }
        }
    }

    // flat input tensor
    int input_matrix_2d_height = INPUT_CHANNEL*KERNEL_HEIGHT*KERNEL_WIDTH;
    int input_matrix_2d_width = ((INPUT_HEIGHT + 2*PADDING - KERNEL_HEIGHT)/STRIDE_HEIGHT + 1) *
                                ((INPUT_WIDTH + 2*PADDING - KERNEL_WIDTH)/STRIDE_WIDTH + 1);
    input_2d_matrix.resize(input_matrix_2d_height);
    for(int i=0; i<input_matrix_2d_height; ++i)
        input_2d_matrix[i].resize(input_matrix_2d_width);
    int input_tensor_h = 0, input_tensor_w = 0;
    for(int j=0; j<input_matrix_2d_width; ++j)
    {
        int i=0;
        for(int ch=0; ch<INPUT_CHANNEL; ++ch)
        {
            for(int h=0; h<KERNEL_HEIGHT; ++h)
            {
                for(int w=0; w<KERNEL_WIDTH; ++w)
                {
                    input_2d_matrix[i][j] = input_tensor[ch][input_tensor_h+h][input_tensor_w+w];
                    i++;
                }
            }
        }

        input_tensor_w += STRIDE_WIDTH;
        if(input_tensor_w+KERNEL_WIDTH > INPUT_WIDTH+2*PADDING)
        {
            input_tensor_w = 0;
            input_tensor_h += STRIDE_HEIGHT;
        }
    }
}


void padding_2dmat()
{
    // padding weight matrix to align heigh/width to tile height/width
    int weight_height_padding = (TILE_HEIGHT - (weight_2d_matrix.size() % TILE_HEIGHT)) % TILE_HEIGHT;
    int weight_width_padding = (TILE_WIDTH - (weight_2d_matrix[0].size() % TILE_WIDTH)) % TILE_WIDTH;
    for(int i=0; i<weight_2d_matrix.size(); ++i)
    {
        for(int j=0; j<weight_width_padding; ++j)
            weight_2d_matrix[i].push_back(0);
    }
    vector<int> weight_height_padding_vec;
    weight_height_padding_vec.resize(weight_2d_matrix[0].size());
    for(int i=0; i<weight_height_padding; ++i)
        weight_2d_matrix.push_back(weight_height_padding_vec);

    // padding input matrix to align height to tile width
    int input_height_padding = (TILE_WIDTH - (input_2d_matrix.size() % TILE_WIDTH)) % TILE_WIDTH;
    vector<int> input_height_padding_vec;
    input_height_padding_vec.resize(input_2d_matrix[0].size());
    for(int i=0; i<input_height_padding; ++i)
        input_2d_matrix.push_back(input_height_padding_vec);
}


void cim_matmul_simulation()
{
    output_2d_matrix.resize(weight_2d_matrix.size());
    for(int i=0; i<output_2d_matrix.size(); ++i)
        output_2d_matrix[i].resize(input_2d_matrix[0].size());
    
    for(int i=0; i<output_2d_matrix.size(); ++i)
    {
        for(int j=0; j<output_2d_matrix[0].size(); ++j)
        {
            for(int k=0; k<weight_2d_matrix[0].size(); k+=CIM_INPUT_SIZE)
            {
                int tmp_partial_sum = 0;
                for(int k_in=0; k_in<CIM_INPUT_SIZE; ++k_in)
                {
                    tmp_partial_sum += weight_2d_matrix[i][k+k_in]*input_2d_matrix[k+k_in][j];
                }
                // conduct CIM's precision cast
                int sign_bit = (tmp_partial_sum >> 14) & 1;
                int high_bits =((sign_bit ? -1 : 0) >> ADC_PRECISION) << ADC_PRECISION;
                tmp_partial_sum = (tmp_partial_sum >> (14-ADC_PRECISION+1)) & ((1<<ADC_PRECISION) - 1);
                tmp_partial_sum += high_bits;
                // add to output
                output_2d_matrix[i][j] += tmp_partial_sum;
            }
        }
    }
}


void write_software_simulation_results()
{
    string output_matrix_file = string(ROOT_DIR)+string(SOFTWARE_RESULT_FILE_NAME);
    ofstream output_matrix_of(output_matrix_file);

    for(int i=0; i<output_2d_matrix.size(); ++i)
    {
        for(int j=0; j<output_2d_matrix[0].size(); ++j)
        {
            output_matrix_of << left << setw(5) << output_2d_matrix[i][j];
        }
        output_matrix_of << endl;
    }
}


int main()
{
    read_tensors();
    flat_conv_to_matmul();
    padding_2dmat();
    cim_matmul_simulation();
    write_software_simulation_results();
    return 0;
}