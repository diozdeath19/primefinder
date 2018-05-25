#define OUTPUT "output"
#define BLOCK_SIZE 1024

#include <iostream>
#include <string>
#include <fstream>	//Writing to files
#include <chrono>	//Keep track of time
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <cuda_runtime.h>
// to remove intellisense highlighting
#include <device_launch_parameters.h>
#ifndef __CUDACC__
#define __CUDACC__
#endif
#include <algorithm>
#include "device_launch_parameters.h"

#include "boinc_api.h"
#include <stdio.h>

using namespace std::chrono;


__global__ static void FindPrimes(char *num, long start, long end){
	long id = blockIdx.x * blockDim.x + threadIdx.x + start;
  if(id >= 2 && id <= end && id != 2 && id != 3 && id != 5 && id != 7) {
    if((id % 2 == 0) || (id % 3 == 0) || (id % 5 == 0) || (id % 7 == 0)) {
      num[id - start] = '1';
    }
  }
}

int main(int argc, char* argv[]) {
	long start_range = 2;
  long end_range = 500000;
  for (int i=0; i<argc; i++) {
    if (!strcmp(argv[i], "-start")) {
      start_range = atol(argv[++i]);
    }
    if (!strcmp(argv[i], "-end")) {
      end_range = atol(argv[++i]);
    }
  }

  if(start_range >= end_range) {
    return 0;
  }

  int retval;
  char buf[256], output_path[512];
  MFILE out;
  double procent = 100;

  retval = boinc_init();
  if (retval) {
      fprintf(stderr,
          "%s boinc_init returned %d\n",
          boinc_msg_prefix(buf, sizeof(buf)), retval
      );
      exit(retval);
  }

  char *gpudata;
  long range = end_range - start_range;
  char *cpudata = new char[range]();

  //memset(cpudata, '0', range);

	//Allocate memory
	cudaMalloc((void**)&gpudata, sizeof(char)*range);

	//Copy to GPU
	cudaMemcpy(gpudata, cpudata, sizeof(char)*range, cudaMemcpyHostToDevice);
	
	float gpu_elapsed_time_ms;
  // some events to count the execution time
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  long GRID_SIZE = (range + BLOCK_SIZE - 1) / BLOCK_SIZE;

  cudaEventRecord(start, 0);
	//Kernel call on the GPU
	FindPrimes << <GRID_SIZE, BLOCK_SIZE >> >(gpudata, start_range, end_range);
	
	//Synchronize the device and the host
	cudaDeviceSynchronize();

	//Copy from GPU back onto host
	cudaMemcpy(cpudata, gpudata, sizeof(char)*range, cudaMemcpyDeviceToHost);

	cudaEventRecord(stop, 0);

	cudaEventSynchronize(start);
  cudaEventSynchronize(stop);

  // compute time elapse on GPU computing
  cudaEventElapsedTime(&gpu_elapsed_time_ms, start, stop);

  /*  
  for (long i = start_range; i < end_range; i++) {
    if(cpudata[i - start_range] == '\0') {
      printf("%ld\t", i);
    }
	}
  */
  
	//Free the memory on the GPU
	cudaFree(gpudata);

	//Reset the device for easy profiling
	cudaDeviceReset();

  boinc_resolve_filename(OUTPUT, output_path, sizeof(output_path));

  retval = out.open(output_path, "a+");
  
  if (retval) {
      fprintf(stderr,
          "%s APP:  output open failed:\n",
          boinc_msg_prefix(buf, sizeof(buf))
      );
      fprintf(stderr,
          "%s resolved name %s, retval %d\n",
          boinc_msg_prefix(buf, sizeof(buf)), output_path, retval
      );
      perror("open");
      exit(1);
  }
  
  out.printf("Time elapsed on prime finding of range from %ld to %ld = %f ms\n\n", start_range, end_range, gpu_elapsed_time_ms);
  retval = out.flush(); //force the output file to be closed.
  if (retval) {
      fprintf(stderr,
          "%s APP: primefinder flush failed %d\n",
          boinc_msg_prefix(buf, sizeof(buf)), retval
      );
      exit(1);
  }

  boinc_fraction_done(procent);

  boinc_finish(0);

	return 0;
}