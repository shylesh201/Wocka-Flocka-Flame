#include<stdio.h>
#include<mpi.h>
#define SIZE 4

int main(int argc, char *argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    float sendbuf[SIZE][SIZE] = {
        {1.0,2.0,3.0,4.0},
        {5.0,6.0,7.0,8.0},
        {9.0,10.0,11.0,12.0},
        {13.0,14.0,15.0,16.0}
    };
    float recvbuf[SIZE];
    int source = 0;
    MPI_Scatter(&sendbuf,SIZE,MPI_FLOAT,&recvbuf,SIZE,MPI_FLOAT,source,MPI_COMM_WORLD);
    printf("[%d] I have %f %f %f %f\n",rank,recvbuf[0],recvbuf[1],recvbuf[2],recvbuf[3]);

    float finalsums[SIZE];
    MPI_Reduce(&recvbuf,&finalsums,SIZE,MPI_FLOAT,MPI_SUM,source,MPI_COMM_WORLD);
    if(rank == 0){
        printf("[%d] I have %f %f %f %f\n",rank,finalsums[0],finalsums[1],finalsums[2],finalsums[3]);
    }
    MPI_Finalize();
}
