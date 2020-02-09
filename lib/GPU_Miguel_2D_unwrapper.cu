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

//pixel information
struct PIXEL
{
    //int x;					//x coordinate of the pixel
    //int y;					//y coordinate
    int increment;			//No. of 2*pi to add to the pixel to unwrap it
    int number_of_pixels_in_group;	//No. of pixels in the pixel group
    float value;			//value of the pixel
    float reliability;
    int group;				//group No.
    int new_group;
    struct PIXEL *head;		//pointer to the first pixel in the group in the linked list
    struct PIXEL *last;		//pointer to the last pixel in the group
    struct PIXEL *next;		//pointer to the next pixel in the group
};


//the EDGE is the line that connects two pixels.
//if we have S PIXELs, then we have S horizental edges and S vertical edges
struct EDGE
{
    float reliab;			//reliabilty of the edge and it depends on the two pixels
    PIXEL *pointer_1;		//pointer to the first pixel
    PIXEL *pointer_2;		//pointer to the second pixel
    int increment;			//No. of 2*pi to add to one of the pixels to unwrap it with respect to the second

    bool operator < (const EDGE& edge) const
    {
        return (reliab < edge.reliab);
    }
};

//---------------start quicker_sort algorithm --------------------------------
#define swap(x,y) {EDGE t; t=x; x=y; y=t;}
#define order(x,y) if (x.reliab > y.reliab) swap(x,y)
#define o2(x,y) order(x,y)
#define o3(x,y,z) o2(x,y); o2(x,z); o2(y,z)

typedef enum {yes, no} yes_no;

__device__ bool find_pivot(EDGE *left, EDGE *right, float *pivot_ptr)
{
    EDGE a, b, c, *p;

    a = *left;
    b = *(left + (right - left) /2 );
    c = *right;
    o3(a,b,c);

    if (a.reliab < b.reliab)
    {
        *pivot_ptr = b.reliab;
        return true;
    }

    if (b.reliab < c.reliab)
    {
        *pivot_ptr = c.reliab;
        return true;
    }

    for (p = left + 1; p <= right; ++p)
    {
        if (p->reliab != left->reliab)
        {
            *pivot_ptr = (p->reliab < left->reliab) ? left->reliab : p->reliab;
            return true;
        }
        return false;
    }
}

__device__ EDGE *partition(EDGE *left, EDGE *right, float pivot)
{
    while (left <= right)
    {
        while (left->reliab < pivot)
            ++left;
        while (right->reliab >= pivot)
            --right;
        if (left < right)
        {
            swap (*left, *right);
            ++left;
            --right;
        }
    }
    return left;
}

__device__ void gpu_quicker_sort(EDGE *left, EDGE *right)
{
    EDGE *p;
    float pivot;

    if (find_pivot(left, right, &pivot))
    {
        p = partition(left, right, pivot);
        gpu_quicker_sort(left, p - 1);
        gpu_quicker_sort(p, right);
    }
}

__global__ void quicker_sort(EDGE *left, EDGE *right)
{
    EDGE *p;
    float pivot;

    if (find_pivot(left, right, &pivot))
    {
        p = partition(left, right, pivot);
        gpu_quicker_sort(left, p - 1);
        gpu_quicker_sort(p, right);
    }
}

//--------------end quicker_sort algorithm -----------------------------------

//--------------------start initialse pixels ----------------------------------
//initialse pixels. See the explanation of the pixel class above.
//initially every pixel is a group by its self
__global__
void  initialisePIXELs(float *WrappedImage, PIXEL *pixel, int image_width, int image_height, curandState *d_rand_state)
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    PIXEL *pixel_pointer;
    float *wrapped_image_pointer;

    for(int i = index; i < image_width*image_height; i += stride) {
        pixel_pointer = pixel + i;
        wrapped_image_pointer = WrappedImage + i;
        pixel_pointer->increment = 0;
        pixel_pointer->number_of_pixels_in_group = 1;
        pixel_pointer->value = *wrapped_image_pointer;
        pixel_pointer->reliability = 9999999.0 + curand_uniform(&d_rand_state[index]);
        pixel_pointer->head = pixel_pointer;
        pixel_pointer->last = pixel_pointer;
        pixel_pointer->next = NULL;
        pixel_pointer->new_group = 0;
        pixel_pointer->group = -1;
    }
}
//-------------------end initialise pixels -----------

//gamma function in the paper
__device__ float wrap(float pixel_value)
{
    float wrapped_pixel_value;
    if (pixel_value > PI)	wrapped_pixel_value = pixel_value - TWOPI;
    else if (pixel_value < -PI)	wrapped_pixel_value = pixel_value + TWOPI;
    else wrapped_pixel_value = pixel_value;

    return wrapped_pixel_value;
}

// pixelL_value is the left pixel,	pixelR_value is the right pixel
__device__ int find_wrap(float pixelL_value, float pixelR_value)
{
    float difference;
    int wrap_value;
    difference = pixelL_value - pixelR_value;

    if (difference > PI){
        wrap_value = -1;
    }
    else if (difference < -PI){
        wrap_value = 1;
    }
    else {
        wrap_value = 0;
    }

    return wrap_value;
}

__global__ void calculate_reliability(float *wrappedImage, PIXEL *pixel, int image_width, int image_height)
{
    int image_width_plus_one = image_width + 1;
    int image_width_minus_one = image_width - 1;
    PIXEL *pixel_pointer = pixel + image_width_plus_one;
    float *WIP = wrappedImage + image_width_plus_one; //WIP is the wrapped image pointer
    float H, V, D1, D2;

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;


    for(int i = index; i < (image_height-1)*(image_width); i += stride){
        // Ignore the first or last pixel in each row
        if(index % image_width == 0 || index % image_width == image_width - 1){
            continue;
        }

        pixel_pointer = pixel + image_width_plus_one + index;
        WIP = wrappedImage + image_width_plus_one + index;

        H = wrap(*(WIP - 1) - *WIP) - wrap(*WIP - *(WIP + 1));
        V = wrap(*(WIP - image_width) - *WIP) - wrap(*WIP - *(WIP + image_width));
        D1 = wrap(*(WIP - image_width_plus_one) - *WIP) - wrap(*WIP - *(WIP + image_width_plus_one));
        D2 = wrap(*(WIP - image_width_minus_one) - *WIP) - wrap(*WIP - *(WIP + image_width_minus_one));
        pixel_pointer->reliability = H*H + V*V + D1*D1 + D2*D2;
    }

    /*
    for (int i = 1; i < image_height -1; ++i)
    {
        for (int j = 1; j < image_width - 1; ++j)
        {
            H = wrap(*(WIP - 1) - *WIP) - wrap(*WIP - *(WIP + 1));
            V = wrap(*(WIP - image_width) - *WIP) - wrap(*WIP - *(WIP + image_width));
            D1 = wrap(*(WIP - image_width_plus_one) - *WIP) - wrap(*WIP - *(WIP + image_width_plus_one));
            D2 = wrap(*(WIP - image_width_minus_one) - *WIP) - wrap(*WIP - *(WIP + image_width_minus_one));
            pixel_pointer->reliability = H*H + V*V + D1*D1 + D2*D2;
            pixel_pointer++;
            WIP++;
        }
        pixel_pointer += 2;
        WIP += 2;
    }*/
}

//calculate the reliability of the horizental edges of the image
//it is calculated by adding the reliability of pixel and the relibility of
//its right neighbour
//edge is calculated between a pixel and its next neighbour
__global__ void horizontalEDGEs(PIXEL *pixel, EDGE *edge, int image_width, int image_height)
{
    EDGE *edge_pointer = edge;
    PIXEL *pixel_pointer = pixel;
    char mybuff1[50];

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;


    for(int i = index; i < image_height*image_width; i += stride){
        if(i % image_width == image_width - 1){
            continue;
        }
        pixel_pointer = pixel + i;
        int edge_pos = (i % (image_width)) + ((i/(image_width))*(image_width-1));
        edge_pointer = edge + edge_pos;

        edge_pointer->pointer_1 = pixel_pointer;
        edge_pointer->pointer_2 = (pixel_pointer+1);
        edge_pointer->reliab = pixel_pointer->reliability + (pixel_pointer + 1)->reliability;
        edge_pointer->increment = find_wrap(pixel_pointer->value, (pixel_pointer + 1)->value);
    }

    /*
    for (int i = 0; i < image_height; i++)
    {
        for (int j = 0; j < image_width - 1; j++)
        {
            edge_pointer->pointer_1 = pixel_pointer;
            edge_pointer->pointer_2 = (pixel_pointer+1);
            edge_pointer->reliab = pixel_pointer->reliability + (pixel_pointer + 1)->reliability;
            edge_pointer->increment = find_wrap(pixel_pointer->value, (pixel_pointer + 1)->value);
            if(edge_pointer->increment != 0){
                //mexPrintf("Inc\n");
                //sprintf (mybuff1, "%d", edge_pointer->increment);
                //mexPrintf(mybuff1);
                //mexPrintf("\n");
            }
            pixel_pointer++;
            edge_pointer++;
        }
        pixel_pointer++;
    }*/
}

//calculate the reliability of the vertical EDGEs of the image
//it is calculated by adding the reliability of pixel and the relibility of
//its lower neighbour in the image.
__global__ void  verticalEDGEs(PIXEL *pixel, EDGE *edge, int image_width, int image_height)
{
    PIXEL *pixel_pointer = pixel;
    EDGE *edge_pointer = edge + (image_height) * (image_width - 1);
    char mybuff1[50];

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for(int i = index; i < (image_height-1)*(image_width); i += stride) {
        pixel_pointer = pixel + i;
        edge_pointer = edge + i + ((image_height) * (image_width - 1));

        edge_pointer->pointer_1 = pixel_pointer;
        edge_pointer->pointer_2 = (pixel_pointer + image_width);
        edge_pointer->reliab = pixel_pointer->reliability + (pixel_pointer + image_width)->reliability;
        edge_pointer->increment = find_wrap(pixel_pointer->value, (pixel_pointer + image_width)->value);
    }

    /*
    for (int i=0; i<image_height - 1; i++)
    {
        for (int j=0; j < image_width; j++)
        {
            edge_pointer->pointer_1 = pixel_pointer;
            edge_pointer->pointer_2 = (pixel_pointer + image_width);
            edge_pointer->reliab = pixel_pointer->reliability + (pixel_pointer + image_width)->reliability;
            edge_pointer->increment = find_wrap(pixel_pointer->value, (pixel_pointer + image_width)->value);
            if(edge_pointer->increment != 0){
                //mexPrintf("Inc\n");
                //sprintf (mybuff1, "%d", edge_pointer->increment);
                //mexPrintf(mybuff1);
                //mexPrintf("\n");
            }
            pixel_pointer++;
            edge_pointer++;
        } //j loop
    } // i loop
    */
}

//gather the pixels of the image into groups
__global__ void  gatherPIXELs(EDGE *edge, int image_width, int image_height)
{
    int k;
    char mybuff1[50], mybuff2[50],mybuff3[50];

    //Number of rialiable edges (not at the borders of the image)
    int no_EDGEs = (image_width - 1) * (image_height) + (image_width) * (image_height - 1);
    PIXEL *PIXEL1;
    PIXEL *PIXEL2;

    PIXEL *group1;
    PIXEL *group2;
    EDGE *pointer_edge = edge;
    int incremento;

    for (k = 0; k < no_EDGEs; k++)
    {
        PIXEL1 = pointer_edge->pointer_1;
        PIXEL2 = pointer_edge->pointer_2;

        //PIXEL 1 and PIXEL 2 belong to different groups
        //initially each pixel is a group by it self and one pixel can construct a group
        //no else or else if to this if
        if (PIXEL2->head != PIXEL1->head)
        {

            /*sprintf (mybuff1, "%f", pointer_edge->reliab);
            sprintf (mybuff2, "%f", PIXEL1->value);
            sprintf (mybuff3, "%f", PIXEL2->value);
            mexPrintf("Pix A: ");
            mexPrintf(mybuff2);
            mexPrintf(" - Pix B: ");
            mexPrintf(mybuff3);
            mexPrintf(" - ");
            mexPrintf(mybuff1);
            mexPrintf(" - ");*/
            //PIXEL 2 is alone in its group
            //merge this pixel with PIXEL 1 group and find the number of 2 pi to add
            //to or subtract to unwrap it
            if ((PIXEL2->next == NULL) && (PIXEL2->head == PIXEL2))
            {
                //mexPrintf("New B\n");
                PIXEL1->head->last->next = PIXEL2;
                PIXEL1->head->last = PIXEL2;
                (PIXEL1->head->number_of_pixels_in_group)++;
                PIXEL2->head=PIXEL1->head;
                PIXEL2->increment = PIXEL1->increment-pointer_edge->increment;
            }

                //PIXEL 1 is alone in its group
                //merge this pixel with PIXEL 2 group and find the number of 2 pi to add
                //to or subtract to unwrap it
            else if ((PIXEL1->next == NULL) && (PIXEL1->head == PIXEL1))
            {
                //mexPrintf("New A\n");
                PIXEL2->head->last->next = PIXEL1;
                PIXEL2->head->last = PIXEL1;
                (PIXEL2->head->number_of_pixels_in_group)++;
                PIXEL1->head = PIXEL2->head;
                PIXEL1->increment = PIXEL2->increment+pointer_edge->increment;
            }

                //PIXEL 1 and PIXEL 2 both have groups
            else
            {
                group1 = PIXEL1->head;
                group2 = PIXEL2->head;
                //the no. of pixels in PIXEL 1 group is large than the no. of PIXELs
                //in PIXEL 2 group.   Merge PIXEL 2 group to PIXEL 1 group
                //and find the number of wraps between PIXEL 2 group and PIXEL 1 group
                //to unwrap PIXEL 2 group with respect to PIXEL 1 group.
                //the no. of wraps will be added to PIXEL 2 grop in the future
                if (group1->number_of_pixels_in_group > group2->number_of_pixels_in_group)
                {
                    //mexPrintf("Big A\n");
                    //merge PIXEL 2 with PIXEL 1 group
                    group1->last->next = group2;
                    group1->last = group2->last;
                    group1->number_of_pixels_in_group = group1->number_of_pixels_in_group + group2->number_of_pixels_in_group;
                    incremento = PIXEL1->increment-pointer_edge->increment - PIXEL2->increment;
                    //merge the other pixels in PIXEL 2 group to PIXEL 1 group
                    while (group2 != NULL)
                    {
                        group2->head = group1;
                        group2->increment += incremento;
                        group2 = group2->next;
                    }
                }

                    //the no. of PIXELs in PIXEL 2 group is large than the no. of PIXELs
                    //in PIXEL 1 group.   Merge PIXEL 1 group to PIXEL 2 group
                    //and find the number of wraps between PIXEL 2 group and PIXEL 1 group
                    //to unwrap PIXEL 1 group with respect to PIXEL 2 group.
                    //the no. of wraps will be added to PIXEL 1 grop in the future
                else
                {
                    //mexPrintf("Big B\n");
                    //merge PIXEL 1 with PIXEL 2 group
                    group2->last->next = group1;
                    group2->last = group1->last;
                    group2->number_of_pixels_in_group = group2->number_of_pixels_in_group + group1->number_of_pixels_in_group;
                    incremento = PIXEL2->increment + pointer_edge->increment - PIXEL1->increment;
                    //merge the other pixels in PIXEL 2 group to PIXEL 1 group
                    while (group1 != NULL)
                    {
                        group1->head = group2;
                        group1->increment += incremento;
                        group1 = group1->next;
                    } // while
                } // else
            } //else
        } else {
            //mexPrintf("Same group\n");
        };//if

        pointer_edge++;
    }
}

//unwrap the image
__global__ void unwrapImage(PIXEL *pixel, int image_width, int image_height)
{
    int image_size = image_width * image_height;
    PIXEL *pixel_pointer;

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for(int i = index; i < image_size; i += stride) {
        pixel_pointer = pixel + i;
        pixel_pointer->value += TWOPI * (float)(pixel_pointer->increment);
    }
}

//the input to this unwrapper is an array that contains the wrapped phase map.
//copy the image on the buffer passed to this unwrapper to over write the unwrapped
//phase map on the buffer of the wrapped phase map.
__global__ void  returnImage(PIXEL *pixel, float *unwrappedImage, int image_width, int image_height)
{
    int image_size = image_width * image_height;
    float *unwrappedImage_pointer;
    PIXEL *pixel_pointer;

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for(int i = index; i < image_size; i += stride) {
        pixel_pointer = pixel + i;
        unwrappedImage_pointer = unwrappedImage + i;
        *unwrappedImage_pointer = pixel_pointer->value;  //(float) pixel_pointer->reliability;
    }
}

__global__ void init_rand(curandState *state){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    curand_init(1337, idx,0, state);
}

__global__ void gpuUnwrap(float* WrappedImage, float* UnwrappedImage, int image_width, int image_height, curandState *state){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    curand_init(1337, index,0, state);
}

__global__ void init_test_edges(int No_of_Edges, EDGE *test_edges){
    EDGE *test_e;
    for(int i=0; i<No_of_Edges; i++){
        test_e = test_edges + i;

        //if(DEBUG){
        //    mexPrintf("Running test: initialising random value %2d\n", i);
        //}

        test_e->reliab = 0; //rand();
    }
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

    int i, j;
    int image_size = image_height * image_width;
    int two_image_size = 2 * image_size;

    int No_of_Edges = (image_width)*(image_height-1) + (image_width-1)*(image_height);

    int blockSize = 256; //1024;
    int numBlocks = 32; //(image_size + blockSize - 1) / blockSize;

    PIXEL *pixel;
    EDGE *edge;

    if(DEBUG){
        mexPrintf("WrappedImage %2.2f\n", *WrappedImage);
    }

    cudaMallocManaged(&pixel,image_size* sizeof(PIXEL));
    cudaMallocManaged(&edge,No_of_Edges* sizeof(EDGE));

    float* gpuWrappedImage;

    cudaMallocManaged(&gpuWrappedImage,image_size* sizeof(float));
    cudaMemcpy(gpuWrappedImage, WrappedImage, image_size*sizeof(float), cudaMemcpyHostToDevice);

    //initialise the pixels
    if(DEBUG){
        mexPrintf("Initialising pixels\n");
    }

    //mexPrintf("Initialising Random Number")
    curandState *d_rand_state;
    cudaMallocManaged(&d_rand_state,blockSize*numBlocks);

    init_rand<<<numBlocks,blockSize>>>(d_rand_state);
    initialisePIXELs<<<numBlocks,blockSize>>>(gpuWrappedImage, pixel, image_width, image_height, d_rand_state);

    //PIXEL *gpu_pixel;
    //EDGE *gpu_edge;

    //cudaMalloc(&pixel, image_size*sizeof(PIXEL));
    //cudaMalloc(&edge, No_of_Edges*sizeof(EDGE));

    //cudaMemcpy(gpu_pixel, pixel, image_size*sizeof(PIXEL), cudaMemcpyHostToDevice);
    //cudaMemcpy(gpu_edge, edge, No_of_Edges * sizeof(EDGE),cudaMemcpyHostToDevice);

    if(DEBUG){
        mexPrintf("Calculating reliabililty\n");
    }

    calculate_reliability<<<numBlocks,blockSize>>>(gpuWrappedImage, pixel, image_width, image_height); //

    //PIXEL *pixel_pointer = pixel;
    //char mybuff1[50],mybuff2[50],mybuff3[50],mybuff4[50];

    if(DEBUG){
        mexPrintf("Gathering edges\n");
    }

    horizontalEDGEs<<<numBlocks,numBlocks>>>(pixel, edge, image_width, image_height);
    verticalEDGEs<<<numBlocks,blockSize>>>(pixel, edge, image_width, image_height);

    if(DEBUG){
        mexPrintf("Sorting edges\n");
    }

    //sort the EDGEs depending on their reliability. The PIXELs with higher reliability (small value) first
    //if your code stuck because of the quicker_sort() function, then use the quick_sort() function
    //run only one of the two functions (quick_sort() or quicker_sort() )
    //quick_sort(edge, No_of_Edges);
    quicker_sort<<<1,1>>>(edge, edge + No_of_Edges - 1);

    if(DEBUG){
        mexPrintf("Running test\n");
    }

    const int N = 6;
    int A[N] = {1, 4, 2, 8, 5, 7};

    EDGE *test_edges;
    cudaMallocManaged(&test_edges,No_of_Edges* sizeof(EDGE));

    thrust::device_ptr<EDGE> device_test_edges(test_edges);

    if(DEBUG){
        mexPrintf("Running test: initialising random values\n");
    }

    init_test_edges<<<1,1>>>(No_of_Edges, test_edges);

    if(DEBUG){
        mexPrintf("Running test sort\n");
    }

    //cudaDeviceSynchronize();
    //thrust::stable_sort(device_test_edges, device_test_edges + No_of_Edges - 1, thrust::less<EDGE>());

    //thrust::stable_sort(edge,edge+No_of_Edges-1,thrust::less<EDGE>());

    //EDGE *edge_pointer = edge;
    //PIXEL *PIXEL1;
    //PIXEL *PIXEL2;
    //double diff;

    //int a;

    if(DEBUG){
        mexPrintf("Gathering the pixels...\n");
    }

    //gather PIXELs into groups
    gatherPIXELs<<<1,1>>>(edge, image_width, image_height);

    if(DEBUG){
        mexPrintf("Unwrapping Image...\n");
    }

    //unwrap the whole image
    unwrapImage<<<numBlocks,blockSize>>>(pixel, image_width, image_height);

    if(DEBUG){
        mexPrintf("Returning Image...\n");
    }

    float* gpuUnwrappedImage;
    cudaMallocManaged(&gpuUnwrappedImage, image_size * sizeof(float));

    //copy the image from PIXEL structure to the wrapped phase array passed to this function
    returnImage<<<numBlocks,blockSize>>>(pixel, gpuUnwrappedImage, image_width, image_height);

    if(DEBUG){
        mexPrintf("Copying unwrapped image...\n");
    }
    cudaMemcpy(UnwrappedImage, gpuUnwrappedImage, image_size * sizeof(float), cudaMemcpyDeviceToHost);

    if(DEBUG){
        //mexPrintf("Unwrapped Image %2.2f\n", pixel->value);
        //mexPrintf("Unwrapped Image %2.2f\n", *gpuUnwrappedImage);
    }

    cudaDeviceSynchronize();

    cudaFree(edge);
    cudaFree(pixel);
    cudaFree(gpuWrappedImage);
    cudaFree(gpuUnwrappedImage);
    cudaFree(d_rand_state);

    if(DEBUG){
        mexPrintf("Phase successfully retrieved...\n");
    }

    return;
}
