# makefile for openclapp BOINC example appication using NVIDIA GPU on Linux.

BOINC_DIR = /home/${USER}/boinc
BOINC_API_DIR = $(BOINC_DIR)/api
BOINC_LIB_DIR = $(BOINC_DIR)/lib 

CXXFLAGS = -g \
    -I$(BOINC_DIR) \
    -I$(BOINC_LIB_DIR) \
    -I$(BOINC_API_DIR) \
    -I/usr/local/cuda/include \
    -L$(BOINC_LIB_DIR) \
    -L$(BOINC_API_DIR) \
    -L/usr/local/cuda/lib64

#matrix_cuda: matrix_cuda.o
	#g++ -o matrix_cuda matrix_cuda.o $(CXXFLAGS) -lpthread -lcudart -lboinc_api -lboinc

primefinder:
	nvcc -o primefinder main.cu	$(CXXFLAGS) -lcudart -lboinc_api -lboinc -std=c++11
clean:
	rm primefinder boinc* stderr.txt output
