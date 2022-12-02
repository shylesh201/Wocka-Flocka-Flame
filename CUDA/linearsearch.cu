#include<stdio.h>
#include<cuda.h>

__constant__ int key;

__global__ void linsearch(int *a,int *p){
    int t = blockDim.x*blockIdx.x + threadIdx.x;
    if(a[t] == key){
        *p = t;
    }
}
int main(){
    int n,k,*darr,*p,pos=-1;
    n = 10;
    int arr[n] = {1,2,3,4,5,6,7,8,9,0};
    k = 7;
    cudaMalloc((void**)&darr,n*sizeof(int));
    cudaMemcpy(darr,&arr,n*sizeof(int),cudaMemcpyHostToDevice);
    cudaMalloc((void**)&p,sizeof(int));
    cudaMemcpy(p,&pos,sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(key,&k,sizeof(int));
    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    linsearch<<<2,5>>>(darr,p);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaMemcpy(&pos,p,sizeof(int),cudaMemcpyDeviceToHost);
    printf("Element Found At : %d\n",pos);
    cudaFree(p);
    cudaFree(darr);
    return 0;
}
