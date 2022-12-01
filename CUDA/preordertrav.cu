#include<stdio.h>
#define N 8
__device__ struct point {
        int x;
        int y;
};

__device__ struct point succ[N][N];
__device__ int position[N][N];

__global__ void preorder(int *parent, int *sibling, int *child, int *adj, int *preo) {
        int i = threadIdx.x;
        int j = threadIdx.y;
        int gind = j*N+i;
        if(adj[gind]==1) {
                 printf("Edge (%d, %d)\n",i, j);
                if(parent[i] == j) {
                        if(sibling[i]!=(-1)) {
                                struct point pt;
                                pt.x = j;
                                pt.y = sibling[i];
                                succ[i][j] = pt;
                        }
                        else if(parent[j]!=(-1)) {
                                 struct point pt;
                                pt.x = j;
                                pt.y = parent[j];
                                succ[i][j] = pt;
                        }
                        else {
                                 struct point pt;
                                pt.x = i;
                                pt.y = j;
                                succ[i][j] = pt;
                                preo[j] = 1;
                        }
                }
                else {
                        if(child[j]!=(-1)) {
                                 struct point pt;
                                pt.x = j;
                                pt.y = child[j];
                                succ[i][j] = pt;
                        }
                        else {
                                 struct point pt;
                                pt.x = j;
                                pt.y = i;
                                succ[i][j] = pt;
                        }
			}
                __syncthreads();
                if(parent[i]==j) position[i][j] = 0;
                else position[i][j] = 1;
                int logval = (int)ceil(log2((double)(2*(N-1))));
                printf("Successor of (%d, %d) = (%d, %d)\n",i, j, succ[i][j].x, succ[i][j].y);

                for(int k=1; k<=logval; k++) {
                        __syncthreads();
                        struct point pt = succ[i][j];
                        position[i][j] = position[i][j]+position[pt.x][pt.y];
                        succ[i][j] = succ[pt.x][pt.y];
                }
                if(i==parent[j]) preo[j] = N+1-position[i][j];
                __syncthreads();
        }

}

int main() {
        int parents[] = {-1, 0, 0, 1, 1, 2, 4, 4};
        int sibling[] = {-1, 2, -1, 4, -1, -1, 7, -1};
        int children[] = {1, 3, 5, -1, 6, -1, -1, -1};
        int *parent, *sib, *child, *preo, *ordered, *adj;
        ordered = (int *)malloc(sizeof(int)*N);
        cudaMalloc((int **)&parent, sizeof(int)*N);
        cudaMalloc((int **)&sib, sizeof(int)*N);
        cudaMalloc((int **)&child, sizeof(int)*N);
        cudaMalloc((int **)&preo, sizeof(int)*N);
        cudaMalloc((int **)&adj, sizeof(int)*N*N);
        int adjacency[N][N];
        memset(adjacency, 0, sizeof(adjacency));
        for(int i=0; i<N; i++) {
                for(int j=0; j<N; j++) {
                        if(parents[j]!=-1 && parents[j]==i) {
                                adjacency[i][j] = 1;
                                adjacency[j][i] = 1;
                        }
                }
        }
        cudaMemcpy(parent, parents, sizeof(int)*N, cudaMemcpyHostToDevice);
        cudaMemcpy(sib, sibling, sizeof(int)*N, cudaMemcpyHostToDevice);
        cudaMemcpy(child, children, sizeof(int)*N, cudaMemcpyHostToDevice);
        cudaMemcpy(adj, adjacency, sizeof(int)*N*N, cudaMemcpyHostToDevice);
        dim3 grid(1);
        dim3 block(N, N);
        preorder<<<grid, block>>>(parent, sib, child, adj, preo);
        cudaMemcpy(ordered, preo, sizeof(int)*N, cudaMemcpyDeviceToHost);
        int preordered[N];
        for(int i=0; i<N; i++) {
                preordered[ordered[i]-1] = i;
        }
        for(int i=0; i<N; i++) {
                printf("%d ", preordered[i]);
        }
        printf("\n");
        free(ordered);
        cudaFree(parent);
        cudaFree(sib);
        cudaFree(child);
        cudaDeviceReset();
}
