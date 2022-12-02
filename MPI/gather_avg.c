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
    float avg = 0;
    for(int i=0;i<4;i++){
        avg+=recvbuf[i];
    }
    avg = avg/4;
    float anums[SIZE];

    MPI_Gather(&avg,1,MPI_FLOAT,&anums,1,MPI_FLOAT,source,MPI_COMM_WORLD);
    if(rank == 0){
        printf("[%d] I have %f %f %f %f\n",rank,anums[0],anums[1],anums[2],anums[3]);
        float favg = 0;
        for(int i=0;i<4;i++){
            favg+=anums[i];
        }
        favg = favg/4;
        printf("Final Average : %f\n",favg);
    }

    MPI_Finalize();
}
