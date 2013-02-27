# This makefile is configured for the NERSC Dirac cluster
# Needs: 
# 	module load cuda
#	module load matlab

design=MatrixPowers
cc=g++
ccflags=-Wall -O3
cppflags=$(mexinc) 

cuda=/usr/local/cuda
nvcc=$(cuda)/bin/nvcc
culdflags=-L$(cuda)/lib64 -lcudart -lcublas 
nvccflags=-O3 -arch sm_20
include=$(cuda)/include
cuda_sources:= $(wildcard *.cu)
cuda_objs:= $(cuda_sources:.cu=.o)

all:  $(design)


$(design): $(cuda_objs)  
	$(nvcc) $(filter %.o, $^) $(culdflags) -o  $@  

%.o: %.cc
	$(cc) $(ccflags) $(cppflags) -c $< -o $@ 

%.o: %.cu
#	$(nvcc) -c  -Xcompiler -fPIC -I$(include) $(nvccflags) $(cppflags) $<  
	$(nvcc) -c  -Xptxas -dlcm=cg  -I$(include) $(nvccflags) $(cppflags)  $<  

clean:
	rm -f *.o *.$(mexext) *.a
