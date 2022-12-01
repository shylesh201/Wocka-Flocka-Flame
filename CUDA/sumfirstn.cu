#include<stdio.h>
#include<math.h>

__global__ void sum(int *a, int n)
{
int i = threadIdx.x + blockIdx.x * blockDim.x;
for(int j=0; j<=3; j++)
{
if( ( (i % (int)pow(2, j)) == 0 ) && ( (2*i + (int) pow(2, j)) < n) )
{
a[2*i] = a[2*i] + a[2*i + (int)pow(2,j)];
}
}
if(i==0)
printf("###%d",a[0]);
}

int main()
{
int n = 10;
int size = n * sizeof(int);
int *ha;
ha = (int *)malloc(size);

for(int i=1; i<=n; i++)
ha[i-1] = i;

int *da;
cudaMalloc(&da, size);
                           
cudaMemcpy(da, ha, size, cudaMemcpyHostToDevice);

sum<<<1, n/2>>>(da, n);
cudaDeviceSynchronize();

//int s;
//cudaMemcpy(s, da[0], sizeof(int), cudaMemcpyDeviceToHost);

//printf("%d", s);
return 0;
}
