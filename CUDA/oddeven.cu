#include<stdio.h>
#define n 8
__global__ void sort(int *a)
{
    int i=threadIdx.x;
  for(int j=0;j<n;j++)
  {
    if(j%2==0 && (i*2+1)<n)
    {
      if(a[2*i]>a[2*i+1])
      {
        int temp=a[2*i];
        a[2*i]=a[2*i+1];
        a[2*i+1]=temp;
      }
    }
    if(j%2==1 && (2*i+2)<n)
    {
      if(a[2*i+1]>a[2*i+2])
      {
        int temp=a[2*i+1];
        a[2*i+1]=a[2*i+2];
        a[2*i+2]=temp;
      }
    }
  }
}
int main()
{
  int a[n]={2,1,4,9,5,3,6,10};
  int *da;
  cudaMalloc((void**)&da,n*sizeof(int));
  cudaMemcpy(da,&a,n*sizeof(int),cudaMemcpyHostToDevice);
  sort<<<1,n>>>(da);
  cudaMemcpy(&a,da,n*sizeof(int),cudaMemcpyDeviceToHost);
  printf("Sorted Order: ");
  for(int i=0;i<n;i++)
    printf("%d ",a[i]);
  return 0;
}