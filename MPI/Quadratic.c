#include<stdio.h>
#include<mpi.h>
#include<math.h>

int main(int argc, char *argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    int a,b,c;
    double root,D;
    if(rank == 0){
        a = 1;
        b = 4;
        c = 4;
    }
    MPI_Bcast(&a,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Bcast(&b,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Bcast(&c,1,MPI_INT,0,MPI_COMM_WORLD);
    if(rank == 0){
        D = pow(b,2) - 4*a*c;
        root = (-1*b + sqrt(D))/(2*a);
        printf("Root 1 : %f\n",root);
    }
    if(rank == 1){
        D = pow(b,2) - 4*a*c;
        root = (-1*b - sqrt(D))/(2*a);
        printf("Root 2 : %f\n",root);
    }
    MPI_Finalize();
}
