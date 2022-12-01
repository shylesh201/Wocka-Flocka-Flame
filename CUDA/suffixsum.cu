#include<stdio.h>
#include<cuda.h>

__global__ void prefixsum(int *a,int n,double logn)
{
    int i=threadIdx.x;
    for (int j=0;j<logn;j++)
    {   int cd = i-pow(2,j);
        if(i>=pow(2,j))
        {   
            a[cd]=a[i]+a[cd];
        }
    }
}

int main()
{
    int n;
    printf("Enter the number of elements in the array:");
    scanf("%d",&n);
    int a[n];
    printf("Enter the elements of the array:\n");
    for(int i=0;i<n;i++)
    {
        scanf("%d",&a[i]);
    }
    int *d_a;
    double x = log(n)/log(2);
    cudaMalloc((void **)&d_a,n*sizeof(int));
    cudaMemcpy(d_a,a,n*sizeof(int),cudaMemcpyHostToDevice);
    prefixsum<<<1,n>>>(d_a,n,x);
    cudaMemcpy(a,d_a,n*sizeof(int),cudaMemcpyDeviceToHost);
    printf("The prefix sum of the array is:");
    for(int i=0;i<n;i++)
    {
        printf("%d ",a[i]);
    }
    printf("\n");
    cudaFree(d_a);
    return 0;
}