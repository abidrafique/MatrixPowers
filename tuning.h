#ifndef TUNING_H
#define TUNING_H


#define BAND_SIZE     13  
#define NUM_MATRICES    8 

#define NUM_THREADS     512	 
#define MATRIX_POWERS_NUM_THREADS     NUM_THREADS	 
#define NUM_BLOCKS  	160 
#define NUM_REGS    	64 
#define UNROLL      	1 
#define ILP         	1 
#define COLS            BAND_SIZE 
#define THREAD_STORAGE  COLS  
#define MATRIX_POWERS_THREAD_STORAGE  THREAD_STORAGE  
#define HALF_BAND_SIZE  ((COLS-1)/2)
//#define S_PARAM         64 
#define S_PARAM_LIMIT  41 
#define N_ITERATIONS   S_PARAM


#endif
