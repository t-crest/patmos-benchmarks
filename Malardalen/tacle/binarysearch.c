/*************************************************************************/
/*                                                                       */
/*   SNU-RT Benchmark Suite for Worst Case Timing Analysis               */
/*   =====================================================               */
/*                              Collected and Modified by S.-S. Lim      */
/*                                           sslim@archi.snu.ac.kr       */
/*                                         Real-Time Research Group      */
/*                                        Seoul National University      */
/*                                                                       */
/*                                                                       */
/*        < Features > - restrictions for our experimental environment   */
/*                                                                       */
/*          1. Completely structured.                                    */
/*               - There are no unconditional jumps.                     */
/*               - There are no exit from loop bodies.                   */
/*                 (There are no 'break' or 'return' in loop bodies)     */
/*          2. No 'switch' statements.                                   */
/*          3. No 'do..while' statements.                                */
/*          4. Expressions are restricted.                               */
/*               - There are no multiple expressions joined by 'or',     */
/*                'and' operations.                                      */
/*          5. No library calls.                                         */
/*               - All the functions needed are implemented in the       */
/*                 source file.                                          */
/*                                                                       */
/*                                                                       */
/*************************************************************************/
/*                                                                       */
/*  FILE: bs.c                                                           */
/*  SOURCE : Public Domain Code                                          */
/*                                                                       */
/*  DESCRIPTION :                                                        */
/*                                                                       */
/*     Binary search for the array of 15 integer elements.               */
/*                                                                       */
/*  REMARK :                                                             */
/*                                                                       */
/*  EXECUTION TIME :                                                     */
/*                                                                       */
/*                                                                       */
/*************************************************************************/
/* Changes:
 * AJ 2014/04/14: Merged patmos/bench changes (PRINT_RESULTS, return value check),
 *                made data[] initializer ansi C compliant.
 */


#ifdef PRINT_RESULTS
#include <stdio.h>
#endif

struct DATA {
  int  key;
  int  value;
};

struct DATA data[15] = { {1, 100}, {5,200}, {6, 300}, {7, 700}, {8, 900},
                         {9, 250}, {10, 400}, {11, 600}, {12, 800}, {13, 1500},
                         {14, 1200}, {15, 110}, {16, 140}, {17, 133}, {18, 10} };

int cnt1 = 0;


extern int binary_search( int );


int main( void )
{
	int r = binary_search(8);
#ifdef PRINT_RESULTS
        printf("binary_search: r=%d\n", r);
#endif
        if(r != 900) return (1);
        if(cnt1 != 4) return (1);
	return (0);
}


int binary_search( int x )
{
  int fvalue, mid, up, low;


  low = 0;
  up = 14;
  fvalue = -1;


  __llvm_pcmarker(0);
  _Pragma("loopbound min 4 max 4")
  while (low <= up) {
    __llvm_pcmarker(1);
    mid = (low + up) >> 1;

    if ( data[mid].key == x ) {  /* found */
      up = low - 1;
      fvalue = data[mid].value;
    } else

    if ( data[mid].key > x ) {  /* not found */
      up = mid - 1;
    } else {
      low = mid + 1;
    }
    
    cnt1++;
  }

#ifdef PRINT_RESULTS
	printf("bs: Loop Count : %d\n", cnt1);
#endif
  return fvalue;
}

