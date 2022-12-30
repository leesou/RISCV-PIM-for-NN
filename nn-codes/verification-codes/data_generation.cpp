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

vector<vector<vector<int> > > input_matrix_tiles;
vector<vector<vector<int> > > weight_matrix_tiles;


void init_tensors()
{
    // init input tensor
    input_tensor.resize(INPUT_CHANNEL);
    for(int i=0; i<INPUT_CHANNEL; ++i)
    {
        input_tensor[i].resize(INPUT_HEIGHT);
        for(int j=0; j<INPUT_HEIGHT; ++j)
        {
            input_tensor[i][j].resize(INPUT_WIDTH);
            for(int k=0; k<INPUT_WIDTH; ++k)
            {
                input_tensor[i][j][k] = rand() % (1<<INPUT_PRECISION);
            }
        }
    }

    // init weight tensor
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
                    weight_tensor[i][j][k][l] = rand() % (1<<WEIGHT_PRECISION);
                }
            }
        }
    }
}


void padding_input_tensor()
{
    vector<int> padding;
    padding.resize(INPUT_WIDTH+2*PADDING);
    for(int i=0; i<INPUT_CHANNEL; ++i)
    {
        for(int j=0; j<INPUT_HEIGHT; ++j)
        {
            for(int k=0; k<PADDING; ++k)
            {
                input_tensor[i][j].push_back(0);
                input_tensor[i][j].insert(input_tensor[i][j].begin(), 0);
                
            }
        }
        
        for(int k=0; k<PADDING; ++k)
        {
            input_tensor[i].push_back(padding);
            input_tensor[i].insert(input_tensor[i].begin(), padding);
        }
    }
}


void write_tensors()
{
    // write input tensor
    string input_tensor_file = string(ROOT_DIR)+string(INPUT_TENSOR_FILE_NAME);
    ofstream input_tensor_of(input_tensor_file);
    for(int i=0; i<INPUT_CHANNEL; ++i)
    {
        for(int j=0; j<INPUT_HEIGHT+2*PADDING; ++j)
        {
            for(int k=0; k<INPUT_WIDTH+2*PADDING; ++k)
            {
                input_tensor_of << left << setw(5) << input_tensor[i][j][k];
            }
            input_tensor_of << endl;
        }
        input_tensor_of << endl;
    }

    // write weight tensor
    string weight_tensor_file = string(ROOT_DIR)+string(WEIGHT_TENSOR_FILE_NAME);
    ofstream weight_tensor_of(weight_tensor_file);
    for(int i=0; i<OUTPUT_CHANNEL; ++i)
    {
        for(int j=0; j<INPUT_CHANNEL; ++j)
        {
            for(int k=0; k<KERNEL_HEIGHT; ++k)
            {
                for(int l=0; l<KERNEL_WIDTH; ++l)
                {
                    weight_tensor_of << left << setw(5) << weight_tensor[i][j][k][l];
                }
                weight_tensor_of << endl;
            }
            weight_tensor_of << endl;
        }
        weight_tensor_of << endl;
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


void write_2d_matrices()
{
    // write weight matrix
    string weight_matrix_file = string(ROOT_DIR)+string(WEIGHT_2D_MATRIX_FILE_NAME);
    ofstream weight_matrix_of(weight_matrix_file);
    for(int i=0; i<weight_2d_matrix.size(); ++i)
    {
        for(int j=0; j<weight_2d_matrix[0].size(); ++j)
            weight_matrix_of << left << setw(5) << weight_2d_matrix[i][j];
        weight_matrix_of << endl;
    }

    // wirte input matrix
    string input_matrix_file = string(ROOT_DIR)+string(INPUT_2D_MATRIX_FILE_NAME);
    ofstream input_matrix_of(input_matrix_file);
    for(int i=0; i<input_2d_matrix.size(); ++i)
    {
        for(int j=0; j<input_2d_matrix[0].size(); ++j)
            input_matrix_of << left << setw(5) << input_2d_matrix[i][j];
        input_matrix_of << endl;
    }
}


void split_matrices_to_tiles()
{
    // split weight matrix
    int tile_height_num = weight_2d_matrix.size()/TILE_HEIGHT;
    int tile_width_num = weight_2d_matrix[0].size()/TILE_WIDTH;
    // init tiles
    weight_matrix_tiles.resize(tile_height_num*tile_width_num);
    for(int i=0; i<weight_matrix_tiles.size(); ++i)
    {
        weight_matrix_tiles[i].resize(TILE_HEIGHT);
        for(int j=0; j<weight_matrix_tiles[i].size(); ++j)
            weight_matrix_tiles[i][j].resize(TILE_WIDTH);
    }
    // write data
    for(int th=0; th<tile_height_num; ++th)
    {
        for(int tw=0; tw<tile_width_num; ++tw)
        {
            int start_h = th*TILE_HEIGHT;
            int start_w = tw*TILE_WIDTH;
            int tile_idx = th*tile_width_num+tw;
            for(int i=0; i<TILE_HEIGHT; ++i)
            {
                for(int j=0; j<TILE_WIDTH; ++j)
                {
                    weight_matrix_tiles[tile_idx][i][j] = weight_2d_matrix[start_h+i][start_w+j];
                }
            }
        }
    }

    // split input matrix and transpose each tile
    int tile_num = input_2d_matrix.size()/TILE_WIDTH;
    // init tiles
    input_matrix_tiles.resize(tile_num);
    for(int i=0; i<tile_num; ++i)
    {
        // transpose tiles
        input_matrix_tiles[i].resize(input_2d_matrix[0].size());
        for(int j=0; j<input_matrix_tiles[i].size(); ++j)
        {
            input_matrix_tiles[i][j].resize(TILE_WIDTH);
        }
    }
    // write data
    for(int tile=0; tile<tile_num; ++tile)
    {
        for(int h=tile*TILE_WIDTH; h<(tile+1)*TILE_WIDTH; ++h)
        {
            for(int w=0; w<input_2d_matrix[0].size(); ++w)
            {
                input_matrix_tiles[tile][w][h-tile*TILE_WIDTH] = input_2d_matrix[h][w];
            }
        }
    }
}


void write_ram()
{
    // weight and input matrices are written in tile order
    // weight tiles in the same rows are first written, the following rows
    // for each input tile, data are written in transposed manner
    // since weight values are 8bits and input values are 4bits, every 4 weight/8 input are packed together
    string ram_file_name = string(ROOT_DIR)+string(RAM_FILE_NAME);
    ofstream ram_of(ram_file_name);

    // write weight matrix tile by tile first
    // check initial address
    if(WEIGHT_MATRIX_ADDR!=0)
    {
        cout << "you should set weight matrix start at 0" << endl;
        exit(-1);
    }
    // write data
    for(int tile=0; tile<weight_matrix_tiles.size(); ++tile)
    {
        int cnt = 0;
        for(int i=0; i<weight_matrix_tiles[tile].size(); ++i)
        {
            for(int j=0; j<weight_matrix_tiles[tile][0].size(); ++j)
            {
                ram_of << setfill('0') << setw(WEIGHT_PRECISION/4) << setbase(16) << weight_matrix_tiles[tile][i][j];
                cnt++;
                if(cnt % int(RAM_PRECISION/WEIGHT_PRECISION) == 0)
                    ram_of << endl;
            }
        }
    }
    // int cnt = 0;
    // for(int i=0; i<weight_2d_matrix.size(); ++i)
    // {
    //     for(int j=0; j<weight_2d_matrix[0].size(); ++j)
    //     {
    //         ram_of << setfill('0') << setw(WEIGHT_PRECISION/4) << setbase(16) << weight_2d_matrix[i][j];
    //         cnt++;
    //         if(cnt % int(RAM_PRECISION/WEIGHT_PRECISION) == 0)
    //             ram_of << endl;
    //     }
    // }

    // write input matrix tile by tile
    // check correctness of initial address
    int padding_byte_num = INPUT_MATRIX_ADDR - weight_2d_matrix.size()*weight_2d_matrix[0].size();
    if(padding_byte_num < 0)
    {
        cout << "you should put input matrix at higher address" << endl;
        exit(-1);
    }
    if(INPUT_MATRIX_ADDR % RAM_PRECISION != 0)
    {
        cout << "you should align input matrix's initial address to ram's granularity" << endl;
        exit(-1);
    }
    // fill zeros between weight matrix and input matrix
    for(int i=0; i<padding_byte_num; ++i)
    {
        ram_of << setfill('0') << setw(2) << setbase(16) << 0;
        if((i+1) % (RAM_PRECISION/8) == 0)
            ram_of << endl;
    }
    // write input matrix
    for(int tile=0; tile<input_matrix_tiles.size(); ++tile)
    {
        int cnt = 0;
        for(int i=0; i<input_matrix_tiles[tile].size(); ++i)
        {
            for(int j=0; j<input_matrix_tiles[tile][0].size(); ++j)
            {
                ram_of << setfill('0') << setw(INPUT_PRECISION/4) << setbase(16) << input_matrix_tiles[tile][i][j];
                cnt++;
                if(cnt % int(RAM_PRECISION/INPUT_PRECISION) == 0)
                    ram_of << endl;
            }
        }
    }
}


int main()
{
    init_tensors();
    if(PADDING)
        padding_input_tensor();
    write_tensors(); // write tensors to file

    flat_conv_to_matmul();
    padding_2dmat(); // align to tile size in order to simplify asm code
    write_2d_matrices();
    split_matrices_to_tiles();
    write_ram(); // write tensors to ram data

    return 0;
}