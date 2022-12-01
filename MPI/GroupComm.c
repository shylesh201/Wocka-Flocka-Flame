GROUP COMMUNICATION

Broadcast

#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
        int rank;
        int buf;
        const int root=0;

        MPI_Init(&argc, &argv);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);

        if(rank == root) {
           buf = 777;
        }

        printf("[%d]: Before Bcast, buf is %d\n", rank, buf);

        /* everyone calls bcast, data is taken from root and ends up in everyone's buf */
        MPI_Bcast(&buf, 1, MPI_INT, root, MPI_COMM_WORLD);

        printf("[%d]: After Bcast, buf is %d\n", rank, buf);

        MPI_Finalize();
        return 0;
}

------------------------------------------------------------------------
Scatter 

#include "mpi.h"
#include <stdio.h>
#define SIZE 4

main(int argc, char *argv[])  {
int numtasks, rank, sendcount, recvcount, source;
float sendbuf[SIZE][SIZE] = {
  {1.0, 2.0, 3.0, 4.0},
  {5.0, 6.0, 7.0, 8.0},
  {9.0, 10.0, 11.0, 12.0},
  {13.0, 14.0, 15.0, 16.0}  };
float recvbuf[SIZE];

MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &numtasks);

if (numtasks == SIZE) {
  source = 1;
  sendcount = SIZE;
  recvcount = SIZE;
  MPI_Scatter(sendbuf,sendcount,MPI_FLOAT,recvbuf,recvcount,
             MPI_FLOAT,source,MPI_COMM_WORLD);

  printf("rank= %d  Results: %f %f %f %f\n",rank,recvbuf[0],
         recvbuf[1],recvbuf[2],recvbuf[3]);
  }
else
  printf("Must specify %d processors. Terminating.\n",SIZE);

MPI_Finalize();
}

Reduce:

#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
 
/* A simple test of Reduce with all choices of root process */
int main( int argc, char *argv[] )
{
    int errs = 0;
    int rank, size, root;
    int *sendbuf, *recvbuf, i;
    int minsize = 2, count;
    MPI_Comm comm;
 
    MPI_Init( &argc, &argv );
 
    comm = MPI_COMM_WORLD;
    /* Determine the sender and receiver */
    MPI_Comm_rank( comm, &rank );
    MPI_Comm_size( comm, &size );
 
    for (count = 1; count < 130000; count = count * 2) {
        sendbuf = (int *)malloc( count * sizeof(int) );
        recvbuf = (int *)malloc( count * sizeof(int) );
        for (root = 0; root < size; root ++) {
            for (i=0; i<count; i++) sendbuf[i] = i;
            for (i=0; i<count; i++) recvbuf[i] = -1;
            MPI_Reduce( sendbuf, recvbuf, count, MPI_INT, MPI_SUM, root, comm );
            if (rank == root) {
                for (i=0; i<count; i++) {
                    if (recvbuf[i] != i * size) {
                        errs++;
                    }
                }
            }
        }
        free( sendbuf );
        free( recvbuf );
    }
 
    MPI_Finalize();
    return errs;
}
