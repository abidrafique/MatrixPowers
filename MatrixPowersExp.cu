#include<cuda.h>

#include <cusp/io/matrix_market.h>
#include <cusp/dia_matrix.h>
#include <cusp/array2d.h>
#include <cusp/array1d.h>
#include <cusp/print.h>
#include <cusp/multiply.h>
#include <cusp/transpose.h>
#include<stdio.h>
#include<iostream>
#include"timestamp.h"
#include"cuda_macros.h"
#include"matrix_powers_kernel.h"
#include"Print.h"
#define DISPLAY        0 


using namespace std;
int main(int argc, char* argv[])
{
   
   int S_PARAM1= S_PARAM_LIMIT;
//   int Matrices[NUM_MATRICES] ={2000,5000,20000,50000,120000,250000,500000,1000000}; 
   int MatrixSize  = 0;
   float gflops3  = 0;

   //for( int i =0; i<8;i++){//NUM_MATRICES;i++)
{
   
//    MatrixSize = Matrices[i];
    MatrixSize = atoi(argv[1]);

   const int ROWS = MatrixSize;
   int Errors =0;

   char filename[200];
   //sprintf(filename,"/home/abid/Tutorials/MatrixPowers/Benchmarks/band%d_n_%d.mtx",BAND_SIZE,MatrixSize);	
//   sprintf(filename,"Benchmarks/band%d_n_%d.mtx",BAND_SIZE,MatrixSize);	
   sprintf(filename,"%s",argv[2]);	
 
   cusp::dia_matrix<int, float, cusp::device_memory> A;
   cusp::io::read_matrix_market_file(A, filename);
   int n = A.num_cols;
   int m = A.num_rows;
   int num_entries = A.num_entries;
	   
   cusp::dia_matrix<int, float, cusp::host_memory> A_host=A;


 //Generaating Random x	
    cusp::array1d<float, cusp::host_memory> x_host(n);	
//    for(int k=0;k<n;k++)
//	x_host[k] = rand()%10;
   float sum=0; 
    for(int k=0;k<n;k++)
    {
//	x_host[k] = k;//rand()%10;
	sum += (float)k*(float)k; 
	}
    float normx = sqrt(sum);
    for(int k=0;k<n;k++)
    {
	x_host[k] = (float)k/normx;//rand()%10;
//	sum += k*k; 
	}
    
    cusp::array1d<float, cusp::device_memory> x=x_host;	
    cusp::array1d<float, cusp::device_memory> y(m, 0);	

    cuda_sync();
    double ts = timestamp();
    for(int k=0;k<S_PARAM1;k++){
	if(k%2 == 0)
	    cusp::multiply(A,x,y);
	else
	    cusp::multiply(A,y,x);
    }
    cuda_sync();
    double total = timestamp() - ts;
    double flops = S_PARAM1*(2.0*(double) num_entries) - 1;
    double gflops = flops / 1000000000.0;
    gflops = gflops / total;
    if(DISPLAY)
	    cout << "SpMV                           " << total/flops << " seconds. " << gflops << " GFLOPS/s" <<endl;
    else
       	cout << m<<"\t"<<S_PARAM1<<"\t"<< gflops <<endl; 
    cusp::array1d<float, cusp::host_memory> y_host =x ;	
    if(S_PARAM1%2 == 1)	 
	    y_host =y ;	
    for(int S_PARAM=S_PARAM_LIMIT;S_PARAM>=1;S_PARAM--)
   // int S_PARAM=S_PARAM_LIMIT;
    {
	
	float* A_ptr = thrust::raw_pointer_cast(&A_host.values.values[0]);

	float* d_a;
	float* d_x;
	float* d_y;

	float* a = new float[ROWS*COLS];
	float* x1 = new float[ROWS];
	float* y1 = new float[S_PARAM*ROWS];
	for(int i=0;i<COLS;i++){
		for(int j=0;j<ROWS;j++){
			a[i*ROWS+j] =A_ptr[i*ROWS+j];
		}
	}
	for(int i=0;i<ROWS;i++){
		x1[i] = x_host[i];
	}
	cudaMalloc(&d_a,ROWS*COLS*sizeof(float));	
	cudaMalloc(&d_x,(ROWS)*sizeof(float));	
	cudaMemcpy(d_a,a,ROWS*COLS*sizeof(float),cudaMemcpyHostToDevice);
	cudaMemcpy(d_x,x1,(ROWS)*sizeof(float),cudaMemcpyHostToDevice);

	cudaMalloc(&d_y,S_PARAM*ROWS*sizeof(float));	

	int bR       = NUM_THREADS-S_PARAM*2*HALF_BAND_SIZE;
	int num_blks = (ROWS + bR-1)/bR;



	cudaFuncSetCacheConfig(matrix_powers_kernel_3, cudaFuncCachePreferShared);
	cuda_sync();
	ts = timestamp();
        matrix_powers_kernel_3<<<num_blks,MATRIX_POWERS_NUM_THREADS>>>(d_a,d_x,d_y,m,bR,S_PARAM,0);
	cuda_sync();
	total = timestamp() - ts;
	cudaMemcpy(y1,d_y,ROWS*S_PARAM*(sizeof(float)),cudaMemcpyDeviceToHost);
	flops = S_PARAM*(2*num_entries - 1);
	gflops3 = flops / 1000000000.0;
	gflops3 = gflops3 / total;
	for(int i=0;i<m;i++)
	{
		if(y1[(S_PARAM-1)*ROWS+i] != y_host[i])
		{
		        Errors++;
	//		cout<<"Error at %d\n"<<i<<endl;
		}
		else
		{
	//		cout<<"SpMV output = "<<y_host[i]<<" Matrix Powers output = "<< y1[(S_PARAM-1)*ROWS+i]<<endl;
		}
  	}
	if(DISPLAY) 	
        	cout << "Matrix Powers: Reg-Blocking    " << total/flops << " seconds. " << gflops3 << " GFLOPS/s" <<"(m,band)"<<m<<","<<BAND_SIZE<< "  Errors = "<<Errors<<endl; 
	else
	       	cout << m<<"\t"<<S_PARAM<<"\t"<< gflops3 <<endl; 



	cudaFree(d_a);
	cudaFree(d_x);	
	cudaFree(d_y);	
	
	delete[]a;	
	delete[]x1;	
	delete[]y1;	
      }

	
   }
}

