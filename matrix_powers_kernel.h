#ifndef MATRIX_POWERS_H
#define MATRIX_POWRS_H
#include"tuning.h"
//#define MATRIX_POWERS_THREAD_STORAGE  BAND_SIZE  
//#define HALF_BAND_SIZE  ((BAND_SIZE-1)/2)


__device__ void load_a_reg(float * a, float col[], int tid,int pitch,int s)
{
	int tid_shifted = tid - s*HALF_BAND_SIZE;

	if(tid_shifted >=0 && tid_shifted < pitch)
	{	
		for(int i = 0 ; i < MATRIX_POWERS_THREAD_STORAGE; i++)
        	{
	           col[i] = a[tid_shifted + i*pitch];
//	           col[i] = a[tid_shifted*COLS + i];
        	}
	}
	else
	{
		for(int i = 0 ; i < MATRIX_POWERS_THREAD_STORAGE; i++)
        	{
	           col[i] = 0;
        	}
	}
}
__device__ void load_x_reg(float x[], float col[])
{
	if(threadIdx.x >= HALF_BAND_SIZE && threadIdx.x < MATRIX_POWERS_NUM_THREADS-HALF_BAND_SIZE)
	{
		for(int i = 0 ; i < MATRIX_POWERS_THREAD_STORAGE; i++)
        	{
	          col[i] = x[threadIdx.x+i-HALF_BAND_SIZE];
        	}
	}
	
}
__device__ void load_x_sharedMem(float * x, float* col,int tid,int pitch,int s)
{
	int tid_shifted = tid - s*HALF_BAND_SIZE;

	if(tid_shifted >= 0 && tid_shifted < pitch)
           col[threadIdx.x] = x[tid_shifted];
	else
           col[threadIdx.x] = 0;
	
	
}
__device__ void load_a_sharedMem(float * a, float col[], int tid,int pitch, int s)
{
	int tid_shifted = tid - s*HALF_BAND_SIZE;

	if(tid_shifted >=0 && tid_shifted < pitch)
	{	
		for(int i = 0 ; i < MATRIX_POWERS_THREAD_STORAGE; i++)
        	{
	           col[threadIdx.x*MATRIX_POWERS_THREAD_STORAGE+i] = a[tid_shifted + i*pitch];
//	           col[i] = a[tid_shifted*COLS + i];
        	}
	}
	else
	{
		for(int i = 0 ; i < MATRIX_POWERS_THREAD_STORAGE; i++)
        	{
	           col[threadIdx.x*MATRIX_POWERS_THREAD_STORAGE+i] = 0;//a[tid_shifted + i*pitch];
        	}
	}
}
__global__ void matrix_powers_kernel_3(float*a, float*x, float*y,int ROWS,int bR,int s,bool bProfiling)
{
	int tid = blockIdx.x*bR + threadIdx.x;
	float A_block_reg[MATRIX_POWERS_THREAD_STORAGE];
	float sum = 0;
	int index=0;
	int k =0;
	float  x_block[MATRIX_POWERS_THREAD_STORAGE];
	__shared__ float  x_sh[MATRIX_POWERS_NUM_THREADS];
	
	
	load_a_reg(a,A_block_reg,tid,ROWS,s);
	load_x_sharedMem(x,x_sh,tid,ROWS,s);
	__syncthreads();
	
/*int row = tid - s*HALF_BAND_SIZE;
		if(row>= 0 && threadIdx.x >= (s*HALF_BAND_SIZE)  &&  threadIdx.x < (MATRIX_POWERS_NUM_THREADS- (s*HALF_BAND_SIZE)) && row < ROWS )
		{
				y[row] = A_block_reg[0];	
		}*/
	int row = tid - s*HALF_BAND_SIZE;
	for(k =0;k<s;k++)
	{
		load_x_reg(x_sh,x_block);
		__syncthreads();
		sum=0;
		#pragma unroll 
		for(int j =0;j<MATRIX_POWERS_THREAD_STORAGE;j++)
		{
			sum  += A_block_reg[j]*x_block[j];
//			sum  += a[row+ROWS*j]*x_block[j];
		}
		if(row>= 0 && threadIdx.x >= (s*HALF_BAND_SIZE)  &&  threadIdx.x < (MATRIX_POWERS_NUM_THREADS- (s*HALF_BAND_SIZE)) && row < ROWS )
		{
		//	if(1 == sum*bProfiling)
				y[index+row] = sum;	
		}
		x_sh[threadIdx.x] = sum;
		__syncthreads();
		index += ROWS;
		
	}
}

#endif
