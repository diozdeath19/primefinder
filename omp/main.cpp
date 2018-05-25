#define OUTPUT "output"

#include <stdio.h>
#include <omp.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include "boinc_api.h"


 
void FindPrimes(char *num, long range){
	#pragma omp parallel for schedule(static)
  for(long id = 2; id <= range; id++) {
    if(id != 2 && id != 3 && id != 5 && id != 7) {
      if((id % 2 == 0) || (id % 3 == 0) || (id % 5 == 0) || (id % 7 == 0)) {
        num[id] = '1';
      }
    }
  }
}

int main(int argc, char* argv[]) {
	long range = 500000;
  for (int i=0; i<argc; i++) {
    if (!strcmp(argv[i], "-range")) {
      range = atol(argv[++i]);
    }
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

  char *data = (char*)malloc(sizeof(char) * range);

  memset(data, '0', range);

  double begin = omp_get_wtime();

  FindPrimes(data, range);

  double end = omp_get_wtime();

  float gpu_elapsed_time_ms = (float)(end - begin);

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
  
  out.printf("Time elapsed on prime finding of range %d = %f s\n\n", range, gpu_elapsed_time_ms);
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