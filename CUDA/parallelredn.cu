#include<cuda.h>
#include<stdio.h>

__global__ void pararedn(int* a)
{
  int t = threadIdx.x;
  for(int j = 1; j < blockDim.x; j*=2)
  {
    if(t % (2*j) == 0 && (t+j) < blockDim.x)
    {
      a[t] = a[t] + a[t+j];
    }
    //printf("%d ", a[t]);
  }
}

int main() 
{
  int arr[10];
  for(int i = 0; i < 10; i++) 
  {
    arr[i] = i+1;
  }
  for(int i = 0; i < 10; i++)
  {
    printf("%d ", arr[i]);
  }
  int *in;
  cudaMalloc((void**)&in, 10*sizeof(int));
  cudaMemcpy(in, &arr, 10 * sizeof(int), cudaMemcpyHostToDevice);
  //cudaMemcpy(out, &sol, 6 * sizeof(int), cudaMemcpyHostToDevice);
  printf("before call\n");
  pararedn<<<1, 10>>>(in);
  printf("after call\n");
  cudaMemcpy(&arr, in, 10*sizeof(int), cudaMemcpyDeviceToHost);
  printf("%d \n", arr[0]);
  cudaFree(in);
  //cudaFree(out);
}