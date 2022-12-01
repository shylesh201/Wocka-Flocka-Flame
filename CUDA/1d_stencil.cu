#include <cuda_runtime.h>
#include<stdio.h>
#include<sys/time.h>

#define RADIUS 4
#define BDIM 8

// constant memory
__constant__ float coef[RADIUS + 1];

/*
// FD coeffecient
#define a0     0.00000f
#define a1     0.80000f
#define a2    -0.20000f
#define a3     0.03809f
#define a4    -0.00357f
*/

#define a0 0
#define a1 1
#define a2 2
#define a3 3
#define a4 4

double cpuSecond(){
        struct timeval tp;
        gettimeofday(&tp, NULL);
        return ((double)tp.tv_sec + (double)tp.tv_usec*1.e-6);
}

void initialData(float *in,  const int size)
{
    for (int i = 0; i < size; i++)
    {
//        in[i] = (float)(rand() & 0xFF) / 100.0f;
in[i]=i+1;
    }
}

void printData(float *in,  const int size)
{
    for (int i = RADIUS; i < size; i++)
    {
        printf("%f ", in[i]);
    }

    printf("\n");
}

void cpu_stencil_1d (float *in, float *out, int isize)
{
    for (int i = RADIUS; i <= isize; i++)
    {
        float tmp = a1 * (in[i + 1] - in[i - 1])
                    + a2 * (in[i + 2] - in[i - 2])
                    + a3 * (in[i + 3] - in[i - 3])
                    + a4 * (in[i + 4] - in[i - 4]);
        out[i] = tmp;
    }
}


__global__ void stencil_1d(float *in, float *out, int N)
{
    // shared memory
    __shared__ float smem[BDIM + 2 * RADIUS];

    // index to global memory
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

        // index to shared memory for stencil calculatioin
        int sidx = threadIdx.x + RADIUS;

        // Read data from global memory into shared memory
        smem[sidx] = in[idx];
printf("\nsmem[%d]=in[%d] by %d, value is %f",sidx,idx,threadIdx.x,in[idx]);
__syncthreads();
        // read halo part to shared memory
        if (threadIdx.x < RADIUS)
        {
            smem[sidx - RADIUS] = in[idx - RADIUS];
            smem[sidx + BDIM] = in[idx + BDIM];
printf("\nsmem[%d]=in[%d] by %d, value is %f",sidx-RADIUS,idx-RADIUS,threadIdx.x,in[idx-RADIUS]);
printf("\nsmem[%d]=in[%d] by %d,value is %f",sidx+BDIM,idx+BDIM,threadIdx.x,in[idx+BDIM]);
        }

        // Synchronize (ensure all the data is available)
        __syncthreads();

        // Apply the stencil
        float tmp = 0.0f;
#pragma unroll
        for (int i = 1; i <= RADIUS; i++)
        {
            tmp += coef[i] * (smem[sidx + i] - smem[sidx - i]);
        }

        // Store the result
        out[idx] = tmp;
printf("\nin[%d] is %f",idx,in[threadIdx.x]);
printf("\nout[%d] = %f by %d", idx,tmp,threadIdx.x);
}

int main(int argc, char **argv)
{
    // set up device
    int dev = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);
    printf("%s starting transpose at ", argv[0]);
    printf("device %d: %s ", dev, deviceProp.name);
    cudaSetDevice(dev);

    // set up data size
    int isize = 1 << 3;

    size_t nBytes = (isize + 2 * RADIUS) * sizeof(float);
    printf("array size: %d ", isize);

    bool iprint = 1;

    // allocate host memory
    float *h_in    = (float *)malloc(nBytes);
    float *hostRef = (float *)malloc(nBytes);
    float *gpuRef  = (float *)malloc(nBytes);

    // allocate device memory
    float *d_in, *d_out;
    cudaMalloc((float**)&d_in, nBytes);
    cudaMalloc((float**)&d_out, nBytes);

    // initialize host array
    initialData(h_in, isize + 2 * RADIUS);

   // Copy to device
    cudaMemcpy(d_in, h_in, nBytes, cudaMemcpyHostToDevice);

    // set up constant memory
    const float h_coef[] = {a0, a1, a2, a3, a4};
    cudaMemcpyToSymbol( coef, h_coef, (RADIUS + 1) * sizeof(float));

    // launch configuration
    cudaDeviceProp info;
    cudaGetDeviceProperties(&info, 0);
    dim3 block(BDIM, 1);
    dim3 grid(info.maxGridSize[0] < isize / block.x ? info.maxGridSize[0] :
            isize / block.x, 1);
    printf("(grid, block) %d,%d \n ", grid.x, block.x);
    double istart = cpuSecond();
    // Launch stencil_1d() kernel on GPU
    stencil_1d<<<1, 8>>>(d_in + RADIUS, d_out + RADIUS, isize);
    double ielapsed = cpuSecond() - istart;
    // Copy result back to host
    cudaMemcpy(gpuRef, d_out, nBytes, cudaMemcpyDeviceToHost);

    // apply cpu stencil
    double cpustart = cpuSecond();
    cpu_stencil_1d(h_in, hostRef, isize);
    double cpuelapsed = cpuSecond() - cpustart;
    // print out results
    if(iprint)
    { printf("\nisize is %d\n",isize);
        printData(gpuRef, isize);
    //    printData(hostRef, isize);
    }
    printf("GPU Elapsed Time %lf\n",ielapsed);
    printf("CPU Elapsed Time %lf\n",cpuelapsed);
    // Cleanup
    cudaFree(d_in);
    cudaFree(d_out);
    free(h_in);
    free(hostRef);
    free(gpuRef);

    // reset device
    cudaDeviceReset();
    return EXIT_SUCCESS;
}
