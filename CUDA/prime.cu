#include<stdio.h>

__global__ void find_prime(int *a, int x, int y)
{
int i =  threadIdx.x + blockIdx.x * blockDim.x;
if(i<=y-x)
{
int count = 0;
for(int j=2; j<=a[i]; j++)
{       
if(a[i] % j == 0)
{
count = count + 1;
}
}
if(count == 1)
{
;
}
else
{
a[i] = -1;
}
}
}

void init_array(int *A, int x, int y)
{
for(int i=0; i<=y-x; i++)
{
A[i] = x+i;
}
}

int main()
{
int a, b;
int *ha;

printf("a: ");
scanf("%d", &a);
printf("\nb: ");
scanf("%d", &b);

int n = b-a+1;
int size = n * sizeof(int);
ha = (int *)malloc(size);

init_array(ha, a, b);
//for(int i=0; i<=b-a; i++)
//printf("%d ", ha[i]);
//printf("\n");

int *da;
//cudaMalloc((void **) &da, size);
cudaMalloc(&da, size);
cudaMemcpy(da, ha, size, cudaMemcpyHostToDevice);
find_prime<<<1, b-a+1>>>(da, a, b);
//cudaDeviceSynchronize();
int *hb;
hb = (int *)malloc(size);

cudaMemcpy(hb, da, size, cudaMemcpyDeviceToHost);

for(int i=0; i<=b-a; i++)
{
if(hb[i] != -1)
{
printf("%d ", hb[i]);
}
}
printf("\n");
return 0;
}
