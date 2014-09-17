#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define UNLIMIT
#define MAXARRAY 16000 /* this number, if too large, will cause a seg. fault!! */

struct myStringStruct {
  char qstring[32];
};

int compare(const void *elem1, const void *elem2)
{
  int result;
  
  result = strcmp((*((struct myStringStruct *)elem1)).qstring, (*((struct myStringStruct *)elem2)).qstring);

  return (result < 0) ? 1 : ((result == 0) ? 0 : -1);
}

// SH: Put the data into the heap to avoid stack overflows on small boards.
struct myStringStruct array[MAXARRAY];

int
main(int argc, char *argv[]) {
  FILE *fp = stdin;
  int i,count=0;

  // FB - make independent from command-line options
//   if (argc<2) {
//     fprintf(stderr,"Usage: qsort_small <file>\n");
//     exit(-1);
//   }
//   else {
//     fp = fopen(argv[1],"r");

    // FB - fix buffer overflow (wtf?!?)
    while((count < MAXARRAY) && (fscanf(fp, "%s", &array[count].qstring) == 1)) {
	 count++;
    }
//   }
  printf("\nSorting %d elements.\n\n",count);
  qsort(array,count,sizeof(struct myStringStruct),compare);
  
  for(i=0;i<count;i++)
    printf("%s\n", array[i].qstring);
  return 0;
}
