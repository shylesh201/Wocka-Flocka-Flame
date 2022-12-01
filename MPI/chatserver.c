#include<stdio.h>
#include<mpi.h>
#include<stdlib.h>
#define SERVER 1
#define N 2
int main(int argc, char **argv) {
int size, rank;
MPI_Init(&argc, &argv);
MPI_Comm_size(MPI_COMM_WORLD, &size);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Status st;
if(rank == SERVER) {
char val[100];
for(int j = 0; j < N; j++) {
for(int i = 0; i < size; i++) {
if(i != rank) {
MPI_Recv(val, 100, MPI_CHAR, MPI_ANY_SOURCE, 101, MPI_COMM_WORLD, &st);
printf("Message from %d : %s\n", st.MPI_SOURCE, val);
int pos;
for(pos = 0; pos < 100; pos++) {
if(val[pos] < 'A' || val[pos] > 'Z') {
break;
}
}
val[pos] = val[pos - 1] + 1;
MPI_Send(val, 100, MPI_CHAR, st.MPI_SOURCE, 101, MPI_COMM_WORLD);
}
}
}
}
else {
char val[100] = "A";
for(int j = 0; j < N; j++) {
MPI_Send(val, 100, MPI_CHAR, SERVER, 101, MPI_COMM_WORLD);
MPI_Recv(val, 100, MPI_CHAR, SERVER, 101, MPI_COMM_WORLD, &st);
printf("My Rank is : %d Message from server : %s\n", rank,val);
int pos;
for(pos = 0; pos < 100; pos++) {
if(val[pos] < 'A' || val[pos] > 'Z') {
break;
}
}
val[pos] = val[pos - 1] + 1;
}
}
MPI_Finalize();
}
