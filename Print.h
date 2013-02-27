#ifndef Print_h
#define Print_h
#include<cstdio>
#include<cuda.h>
#include<cublas.h>
void PrintDeviceMatrix(float* A, int M, int N);
void PrintDeviceVector(float* A,  int N);
void PrintMatrix(float** A, int M, int N);
void PrintMatrix(float* A, int M, int N);
void PrintVector(float* a, int n);
void PrintVector(int* a, int n);
void CtoFortranFormat(int  M, int N, float* A, float* B);
void FortrantoCFormat(int  M, int N, float* A, float* B);
#endif
