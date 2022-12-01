#include<stdio.h>
#include<cuda.h>
#include <ctype.h>

__global__ void prefixsum(int *a,int n,double logn)
{
    int i=threadIdx.x;
    for (int j=0;j<logn;j++)
    {   int cd = i-pow(2,j);
        if(i>=pow(2,j))
        {   
            a[i]=a[i]+a[cd];
        }
    }
}
__global__ void pack(int *a,char *b){
    int i=threadIdx.x;
    if(b[i]>='A' && b[i]<='Z'){
        b[a[i]-1]=b[i];
    }
}

int main()
{
    int n;
    printf("Enter the size of the array:\n");
    // scanf("%d",&n);
    n=8;
    
    int a[n];
    int bc=0;
    printf("Enter the array:\n");
    char b[n] = {'A','B','C','D','e','f','g','H'};
    for(int i = 0; i < n; i++)
    {
        //scanf("%c",&b[i]);
        if(b[i]>='A' && b[i]<='Z'){
            a[i]=1;
            bc++;
        }
        else{
            a[i]=0;
        }
    }
    int *d_a;
    cudaMalloc((void **)&d_a,n*sizeof(int));
    cudaMemcpy(d_a,a,n*sizeof(int),cudaMemcpyHostToDevice);
    char *d_b;
    cudaMalloc((void **)&d_b,n*sizeof(char));
    cudaMemcpy(d_b,b,n*sizeof(char),cudaMemcpyHostToDevice);
    prefixsum<<<1,n>>>(d_a,n,log2(n));
    cudaMemcpy(a,d_a,n*sizeof(int),cudaMemcpyDeviceToHost);
    printf("The prefix sum of the array is:");
    for(int i=0;i<n;i++)
    {
        printf("%d ",a[i]);
    }
    printf("\n");
    pack<<<1,n>>>(d_a,d_b);
    cudaMemcpy(b,d_b,n*sizeof(char),cudaMemcpyDeviceToHost);
    printf("The packed array is:");
    for(int i=0;i<bc;i++)
    {
        printf("%c ",b[i]);
    }
}