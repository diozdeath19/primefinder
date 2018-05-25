# makefile for openclapp BOINC example appication using NVIDIA GPU on Linux.

BOINC_DIR = /home/${USER}/boinc
BOINC_API_DIR = $(BOINC_DIR)/api
BOINC_LIB_DIR = $(BOINC_DIR)/lib 

CXXFLAGS = -g \
    -I$(BOINC_DIR) \
    -I$(BOINC_LIB_DIR) \
    -I$(BOINC_API_DIR) \
    -L$(BOINC_LIB_DIR) \
    -L$(BOINC_API_DIR) \

primefinder:
	g++ -o primefinder main.cpp	$(CXXFLAGS) -fopenmp -lboinc_api -lboinc
clean:
	rm primefinder boinc* stderr.txt output
