#include<stdio.h>
#include<cuda.h>

__global__ void dot(int *a, int *b, int *c, int nx, int ny)
{
  int k = threadIdx.x;
  c[k] = a[k] * b[k];
}

__global__ void red(int * c)
{
  int t = threadIdx.x;
  printf("%d",blockDim.x);
  for(int a = 1; a < blockDim.x; a *= 2)
  {
    if(t % ( 2*a) == 0 && t+a < blockDim.x)
    {
      c[t] += c[t+a];
    }
  }
}

int main()
{
  int a[4] = {1, 2, 3, 4};
  int b[4] = {1, 2, 3, 4};
  int c[4] = {0, 0, 0, 0};

  int *da, *db, *dc, size = 4*sizeof(int);
  cudaMalloc((void **) & da, size);
  cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
  cudaMalloc((void **)&db, size);
  cudaMemcpy(db, b, size, cudaMemcpyHostToDevice);
  cudaMalloc((void **)&dc, size);
  cudaMemcpy(dc, c, size, cudaMemcpyHostToDevice);
  dot<<<1,4>>>(da, db, dc, 1, 4);
  red<<<1,4>>>(dc);
  cudaMemcpy(&c, dc, size, cudaMemcpyDeviceToHost);
  printf("%d", c[0]);
  return 0;
}
    