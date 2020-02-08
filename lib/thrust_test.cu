//This program is written by Munther Gdeisat and Miguel Arevallilo Herra´ez to program the two-dimensional unwrapper
//entitled "Fast two-dimensional phase-unwrapping algorithm based on sorting by 
//reliability following a noncontinuous path"
//by  Miguel Arevallilo Herra´ez, David R. Burton, Michael J. Lalor, and Munther A. Gdeisat
//published in the Applied Optics, Vol. 41, No. 35, pp. 7437, 2002.
//This program is written on 15th August 2007
//The wrapped phase map is floating point data type. Also, the unwrapped phase map is foloating point
//#include <sys/malloc.h>
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"   //--This one is required

#include <cuda.h>
#include <curand_kernel.h>
#include <curand.h>
#include <thrust/sort.h>
#include <thrust/device_ptr.h>
//#include <stl.h>

__device__ static float PI = 3.141592654;
__device__ static float TWOPI = 6.283185307;

bool DEBUG = true;

struct saxpy_functor
{
    const float a;

    saxpy_functor(float _a) : a(_a) {}

    __host__ __device__
    float operator()(const float& x, const float& y) const {
        return a * x + y;
    }
};

void saxpy_fast(float A, thrust::device_ptr<float> X, thrust::device_ptr<float> Y, int N)
{
    // Y <- A * X + Y
    thrust::transform(X, X+N, Y, Y+N, saxpy_functor(A));
}

__global__ void gpu_derivative_vertical(float* WrappedImage, float* DerivativeImage, int width, int height){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    float* WIP;
    float* DIP;

    for(int i=index; i<width*height; i+=stride){
        WIP = WrappedImage + i;
        DIP = DerivativeImage + i;

        if(i/height == 0){
            *DIP = *(WIP+width) - *WIP;
        } else if(i + width > width*height){
            *DIP = *WIP - *(WIP-width);
        } else {
            *DIP = (*(WIP+width)-*WIP+*WIP-*(WIP-width))/2;
        }
    }
}

__global__ void gpu_derivative_horizontal(float* WrappedImage, float* DerivativeImage, int width, int height){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    float* WIP;
    float* DIP;

    for(int i=index; i<width*height; i+=stride){
        WIP = WrappedImage + i;
        DIP = DerivativeImage + i;

        if(i % width == 0){
            *DIP = *(WIP+1) - *WIP;
        } else if (i % width == width-1){
            *DIP = *WIP - *(WIP-1);
        } else {
            *DIP = (*(WIP+1)-*WIP+*WIP-*(WIP-1))/2;
        }
    }
}

__global__ void gpu_unwrap(float* WrappedImage, float* UnwrappedImage, int width, int height){

}

//the main function of the unwrapper
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Declarations of getting two arrays from Matlab
    //1)input wrapped image  of type float and 2)mask of type unsigned char
    float *WrappedImage = (float *)mxGetData(prhs[0]);
    int image_width = mxGetM(prhs[0]);
    int image_height = mxGetN(prhs[0]);

    //declare a place to store the unwrapped image and return it to Matlab
    const mwSize *dims = mxGetDimensions(prhs[0]);
    plhs[0] = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, mxREAL);
    float *UnwrappedImage = (float *)mxGetPr(plhs[0]);

    int image_size = image_height * image_width;
    int two_image_size = 2 * image_size;

    int No_of_Edges = (image_width)*(image_height-1) + (image_width-1)*(image_height);

    int blockSize = 256; //1024;
    int numBlocks = 32; //(image_size + blockSize - 1) / blockSize;

    const int N = 6;
    int    keys[N] = {  1,   4,   2,   8,   5,   7};
    char values[N] = {'a', 'b', 'c', 'd', 'e', 'f'};

    thrust::sort_by_key(keys, keys + N, values);

    return;
}
