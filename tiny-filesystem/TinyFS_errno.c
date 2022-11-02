#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>

#include "libDisk.h"
#include "libTinyFS.h"
#include "TinyFS_errno.h"


void printErr(int err){
  switch(err){
    case 0:
      printf("Success\n");
      break;
    case -1:
      printf("Error Not Open\n");
      break;
    case -2:  
      printf("No space\n");
      break;
    case -3:
      printf("Error does not exist\n");
      break;
    case -4:
      printf("Error Open R\n");
      break;
    case -5:  
      printf("Error Open W\n");
      break;
    case -6:
      printf("Error FSeek\n");
      break;
    case -7:
      printf("Error FRead\n");
      break;
    case -8:  
      printf("Error FWrite\n");
      break;
    case -9:
      printf("Error FS type\n");
      break;
    case -10:  
      printf("Error F Not Exist\n");
      break;
    case -11:
      printf("Error F Too Small\n");
      break;
    case -12:
      printf("Error Bad Parameter\n");
      break;
    case -13:  
      printf("Error EOF\n");
      break;
    case -14:
      printf("Error Is Dir\n");
      break;
    case -15:
      printf("Error Is Not Dir\n");
      break;
    case -16:  
      printf("Read Only Permission\n");
      break;
  }
}