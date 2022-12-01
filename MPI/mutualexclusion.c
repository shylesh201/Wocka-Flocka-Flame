#include <stdio.h>
#include "mpi.h"
int main(int argc, char **argv)
{
int size, rank;
MPI_Init(&argc, &argv);
MPI_Comm_size(MPI_COMM_WORLD, &size);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
int shared = 0;
if (rank == 0)
{
int queue[10];
for (int j = 0; j < 10; j++)
queue[j] = 0;
int front = 0;
int rear = -1;
int count = 0;
int lock = 0;
int process;
MPI_Status st;
while (1)
{
MPI_Recv(&process, 1, MPI_INT, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &st); if (st.MPI_SOURCE == 0)
break;
printf("Queue has ");
for (int j = front; j < 6; j++)
{
if (queue[j] == 0)
break;
printf("%d ", queue[j]);
}
printf("\n");
if (st.MPI_TAG == 3)
{
shared = process;
int send = queue[front++];
count--;
printf("Process %d changed value is %d\n", st.MPI_SOURCE, shared);
if (send == 0)
break;
printf("Process %d acquired shared resource\n", send);
MPI_Send(&shared, 1, MPI_INT, send, 2, MPI_COMM_WORLD);
}
if (st.MPI_TAG == 1)
{
if (lock == 0 && count == 0)
{
lock = 1;
printf("Process %d acquired shared resource\n", process);
MPI_Send(&shared, 1, MPI_INT, process, 2, MPI_COMM_WORLD);
}
else
{
queue[++rear] = process;
count++;
}
}
}
}
else
{
PDS Lab Exercise 10
MPI_Send(&rank, 1, MPI_INT, 0, 1, MPI_COMM_WORLD);
MPI_Status st;
int recv;
MPI_Recv(&shared, 1, MPI_INT, 0, 2, MPI_COMM_WORLD, &st);
if (st.MPI_TAG == 2)
{
int before = shared;
shared++;
printf("Process %d, Before altering %d; After altering %d\n", rank, before, shared);
MPI_Send(&shared, 1, MPI_INT, 0, 3, MPI_COMM_WORLD);
}
}
MPI_Finalize();
}
