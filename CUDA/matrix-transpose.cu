%%cu
#include<stdio.h>
#include<sys/time.h>

#define N 4
#define M 4
#define BDIMX 2
#define BDIMY 2

__global__ void transpose(int *a, int *b) {
        __shared__ int temp[BDIMY][BDIMX];
        int ix = threadIdx.x + blockIdx.x * blockDim.x;
        int iy = threadIdx.y + blockIdx.y * blockDim.y;
        int ti = iy * N + ix;
        int bidx = threadIdx.x + threadIdx.y * blockDim.x;
        int irow = bidx / blockDim.y;
        int icol = bidx % blockDim.y;
        ix = icol + blockIdx.y * blockDim.y;
        iy = irow + blockIdx.x * blockDim.x;
        int to = iy * M + ix;
        if(ix < N && iy < M) {
                temp[threadIdx.y][threadIdx.x] = a[ti];
                __syncthreads();
                b[to] = temp[icol][irow];
        }
}

double cpuSecond() {
        struct timeval tp;
        gettimeofday(&tp, NULL);
        return ((double)tp.tv_sec + (double)tp.tv_usec*1.e-6);
}

int main() {
        int *a, *b;
        int size = N * M * sizeof(int);
        a = (int* )malloc(size);
        b = (int* )malloc(size);
        for(int i = 0; i < N * M; i++) {
                a[i] = i;
        }
        printf("Initial Array: \n");
        for(int i = 0; i < N; i++) {
                for(int j = 0; j < M; j++) {
                        printf("%d ", a[i * M + j]);
                }
                printf("\n");
        }

        int *da, *db;
        cudaMalloc((void** )&da, size);
        cudaMalloc((void** )&db, size);
        cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
        dim3 block(BDIMX, BDIMY);
        dim3 grid(2, 2);
        double istart = cpuSecond();
        transpose<<<grid, block>>>(da, db);
        cudaDeviceSynchronize();
        double ielapsed = cpuSecond() - istart;
        cudaMemcpy(b, db, size, cudaMemcpyDeviceToHost);
        printf("Final Array: \n");
        for(int i = 0; i < N; i++) {
                for(int j = 0; j < M; j++) {
                        printf("%d ", b[i * M + j]);
                }
                printf("\n");
        }
        printf("Elapsed Time : %lf\n", ielapsed);
}
