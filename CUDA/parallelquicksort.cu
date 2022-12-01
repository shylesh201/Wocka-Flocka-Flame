#include<stdio.h>
#include<time.h>

#define N 20

void initialize(int *a) {
        for(int i = 0; i < N; i++) {
                a[i] = rand() % (100 - 10 + 1) + 10;
        }
}

__device__ int d_size;

__global__ void partition(int *arr, int *lstack, int *hstack, int n) {
        int idx = blockIdx.x * blockDim.x + threadIdx.x;
        d_size = 0;
        __syncthreads();
        if(idx < n) {
                int h = hstack[idx], l = lstack[idx], x = arr[h], i = l - 1;
                int temp;
                for(int j = l; j < h; j++) {
                        if(arr[j] <= x) {
                                i++;
                                temp = arr[i];
                                arr[i] = arr[j];
                                arr[j] = temp;
                        }
                }
                temp = arr[i + 1];
                arr[i + 1] = arr[h];
                arr[h] = temp;
                int p = i + 1;
                if(p - 1 > l) {
                        int ind = atomicAdd(&d_size, 1);
                        lstack[ind] = l;
                        hstack[ind] = p - 1;
                }
                if(p + 1 < h) {
                        int ind = atomicAdd(&d_size, 1);
                        lstack[ind] = p + 1;
                        hstack[ind] = h;
                }
        }
}

void quickSort(int *arr) {
        int low = 0, high = N - 1;
        int lstack[high - low + 1], hstack[high - low + 1];
        int top = -1, *da, *dl, *dh, size = (high - low + 1) * sizeof(int);
        lstack[++top] = low;
        hstack[top] = high;

        cudaMalloc(&da, size);
        cudaMemcpy(da, arr, size, cudaMemcpyHostToDevice);

        cudaMalloc(&dl, size);
        cudaMemcpy(dl, lstack, size, cudaMemcpyHostToDevice);

        cudaMalloc(&dh, size);
        cudaMemcpy(dh, hstack, size, cudaMemcpyHostToDevice);

        int nt, nb, ni;
        nt = nb = ni = 1;

        while(ni > 0) {
                partition<<<nb, nt>>>(da, dl, dh, ni);
                int ans;
                cudaMemcpyFromSymbol(&ans, d_size, sizeof(int),0, cudaMemcpyDeviceToHost);
                if(ans < N * nt) {
                        nt = ans;
                }
                else {
                        nt = N * nt;
                        nb = ans / nt + (ans % nt == 0 ? 0 : 1);
                }
                ni = ans;
                cudaMemcpy(arr, da, (high - low + 1) * sizeof(int), cudaMemcpyDeviceToHost);
        }
}

int main() {
        int *a = (int* )malloc(N * sizeof(int));
        initialize(a);
        quickSort(a);
        for(int i = 0; i < N; i++) {
                printf("%d ", a[i]);
        }
        printf("\n");
}

