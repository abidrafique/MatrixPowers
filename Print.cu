
#include<cstdio>
#include"Print.h"
void PrintDeviceMatrix(float* A, int M, int N)
{
	float * A_1 = new float[M*N];
	float * A_2 = new float[M*N];
	
	
	cublasGetMatrix(M,N,sizeof(float),A,M,A_1,M);
	FortrantoCFormat(M,N,A_1,A_2);
	PrintMatrix(A_2,M,N);

	delete [] A_1;
	delete [] A_2;

	
}
void PrintDeviceVector(float* A,  int N)
{
	float * A_1 = new float[N];
	
	
	cublasGetVector(N,sizeof(float),A,1,A_1,1);
	PrintVector(A_1,N);

	delete [] A_1;

	
}
void PrintMatrix(double** A, int M, int N)
{
	printf("\n");
	for(int i =0;i < M;i++)
	{
		for(int j = 0;j<N;j++)
			printf(" %e\t",A[i][j]);
		printf("\n");
	}
}

void PrintMatrix(double* A, int M, int N)
{
	printf("\n");
	for(int i =0;i < M;i++)
	{	//printf("Row = %d\n",i);
		for(int j = 0;j<N;j++)
			printf(" %1.15f\t",A[j*M+i]);
		printf("\n");
	}
}

void PrintMatrix(float* A, int M, int N)
{
	printf("\n");
	for(int i =0;i < M;i++)
	{	//printf("Row = %d\n",i);
		for(int j = 0;j<N;j++)
			printf(" %1.15f\t",A[i*N+j]);
		printf("\n");
	}
}

void PrintVector(float* a, int n)
{
	for(int i =0;i < n;i++)
	{
		printf(" %f\t",a[i]);
	}

	printf("\n\n");
}

void PrintVector(double* a, int n)
{
	for(int i =0;i < n;i++)
	{
		printf(" %e\t",a[i]);
	}

	printf("\n\n");
}

void PrintVector(int* a, int n)
{
	for(int i =0;i < n;i++)
	{
		printf(" %d\t",a[i]);
	}

	printf("\n");
}
void CtoFortranFormat(int  M, int N, float* A, float* B)
{
	for(int i =0;i<N;i++)
	{
		for(int j =0;j<M;j++)
		{
			B[i*M+j] = A[j*N+i];
		}
	}
}


void FortrantoCFormat(int  M, int N, float* A, float* B)
{
	for(int i =0;i<M;i++)
	{
		for(int j =0;j<N;j++)
		{
			B[i*N+j] = A[j*M+i];
		}
	}
}


