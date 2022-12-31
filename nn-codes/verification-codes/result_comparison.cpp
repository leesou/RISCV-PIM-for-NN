#include <iostream>
#include <fstream>
using namespace std;

//#define ONE_TILE
#define FULL

#ifdef ONE_TILE
    #define SOFTWARE "../../test_data/one_tile_matmul/software_result.txt"
    #define HARDWARE "../../hardware-codes/tb/one_tile_matmul/results/ram.output"
    #define HEIGHT 8
    #define WIDTH 16  
#elif defined(FULL)
    #define SOFTWARE "../../test_data/matmul/software_result.txt"
    #define HARDWARE "../../hardware-codes/tb/matmul/results/ram.output"
    #define HEIGHT 16
    #define WIDTH 196
#endif


int main()
{
    ifstream software(SOFTWARE), hardware(HARDWARE);
    int diff_count = 0;
    int soft, hard;
    for(int i=0; i<HEIGHT; ++i)
    {
        for(int j=0; j<WIDTH; ++j)
        {
            software >> soft;
            hardware >> hard;
            if(soft!=hard)
                diff_count++;
        }
    }

    if(diff_count>0)
        cout << "you have " << diff_count << " different results" << endl;
    else
        cout << "correct!" << endl;
    return 0;
}