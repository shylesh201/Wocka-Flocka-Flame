#include<cuda.h>
#include<stdio.h>
#include<string.h>

__global__ void graph(int *a,int *b,int *c)
{
        int m=threadIdx.x;
        int t=3*threadIdx.x;
        if((a[t]==a[t+1]) || (a[t+1]==a[t+2]))
                b[m]=0;
        atomicAdd(c,b[m]);
}

int main(){
        int i,b[8],c;
        int *da,*db,*dc;
        int a[8][3] = {{0,0,0},{0,0,1},{0,1,0},{0,1,1},{1,0,0},{1,0,1},{1,1,0},{1,1,1}};
        for(i=0;i<8;i++)
        {
                b[i]=1;
        }
        cudaMalloc((void**)&da,24*sizeof(int));
        cudaMalloc((void**)&db,8*sizeof(int));
        cudaMalloc((void**)&dc,sizeof(int));
        cudaMemcpy(da,&a,24*sizeof(int),cudaMemcpyHostToDevice);
        cudaMemcpy(db,&b,8*sizeof(int),cudaMemcpyHostToDevice);
        cudaMemcpy(dc,&c,sizeof(int),cudaMemcpyHostToDevice);
        graph<<<1,8>>>(da,db,dc);
        cudaMemcpy(&b,db,8*sizeof(int),cudaMemcpyDeviceToHost);
        cudaMemcpy(&c,dc,sizeof(int),cudaMemcpyDeviceToHost);
        printf("Possible Combinations are:\n");
        for(i=0;i<8;i++)
        {
                if(b[i]==1)
                        printf("%d%d%d\n",a[i][0],a[i][1],a[i][2]);
        }
        printf("Number of combinatons:%d\n",c);
        return 0;
}
