#include <stdlib.h>
#include <stdio.h>
#include "mpi.h"
void main(int argc, char *argv[])
{
    MPI_Init(&argc, &argv);
    int rank, size, recv, uid, next, prev, round = 1;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Status st;
    // 1.Generate uid
    uid = (rand() * (rank + 1) * size) % 100;
    if (uid < 0)
        uid = uid + 100;
    printf("HI! I am rank %d uid %d\n", rank, uid);
    // 2.Determine next and prev
    next = (rank == size - 1 ? 0 : rank + 1);
    prev = (rank == 0 ? size - 1 : rank - 1);
    // 3.Send uid to next with round no. as 1
    MPI_Send(&uid, 1, MPI_INT, next, round, MPI_COMM_WORLD);
    while (1)
    {
        // 4.Recv uid from prev and check the tag. If tag equal to 201, send 201 to next and terminate. Else check uid and decide to declare as leader(if recv==uid) or send the recv to next process(if recv>uid) by incrementing the round number.

        MPI_Recv(&recv, 1, MPI_INT, prev, MPI_ANY_TAG, MPI_COMM_WORLD, &st);
        if (st.MPI_TAG == 201)
        {
            MPI_Send(&recv, 1, MPI_INT, next, 201, MPI_COMM_WORLD);
            break;
        }
        else
        {
            round = st.MPI_TAG;
            printf("Round %d:My rank %d recieved %d\n", round, rank, recv);
            if (recv == uid)
            {
                printf("I am the leader...Rank %d uid:%d round %d \n", rank, uid, round);
                MPI_Send(&rank, 1, MPI_INT, next, 201, MPI_COMM_WORLD);
                break;
            }
            if (recv > uid)
            {
                MPI_Send(&recv, 1, MPI_INT, next, round + 1, MPI_COMM_WORLD);
            }
        }
    }
    MPI_Finalize();
}
