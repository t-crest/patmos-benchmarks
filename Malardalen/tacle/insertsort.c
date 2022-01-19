/* Remove the following #define for actual WCET analyses! */
/*
#define PROFILING
*/

#ifdef PROFILING
#include <stdio.h>
#endif


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
/*  FILE: insertsort.c                                                   */
/*  SOURCE : Public Domain Code                                          */
/*                                                                       */
/*  DESCRIPTION :                                                        */
/*                                                                       */
/*     Insertion sort for 10 integer numbers.                            */
/*     The integer array a[] is initialized in main function.            */
/*									 */
/*  COMMENTS: Input-data dependent nested loop with worst-case of        */
/*   	      (n^2)/2 iterations (triangular loop).		         */
/*                                                                       */
/*                                                                       */
/*************************************************************************/

/* Changes:
 * AJ 2014/04/15: Merged patmos/bench changes (PRINT_RESULTS, return check)
 */

#ifdef PRINT_RESULTS
#include <stdio.h>
#endif

int             cnt1, cnt2;

unsigned int a[11];

int main( void )
{
  int  i,j, temp;

  #ifdef PROFILING
  /* Profiling variables. Remove for actual WCET analyses. */
  int iters_i = 0, min_i = 100000, max_i = 0;
  int iters_a = 0, min_a = 100000, max_a = 0;
  #endif

  a[0] = 0;   /* assume all data is positive */
  a[1] = 11; a[2]=10;a[3]=9; a[4]=8; a[5]=7; a[6]=6; a[7]=5;
  a[8] =4; a[9]=3; a[10]=2;
  i = 2;
  #ifdef PROFILING
  iters_i = 0;
  #endif
  //__llvm_pcmarker(2);
  _Pragma("loopbound min 9 max 9")
  while(i <= 10){
    //__llvm_pcmarker(3);
    cnt1++;
    #ifdef PROFILING
    iters_i++;
    #endif
    
    j = i;
    cnt2 = 0;
    #ifdef PROFILING
    iters_a = 0;
    #endif
    //__llvm_pcmarker(0);
    _Pragma("loopbound min 1 max 9")
    while (a[j] < a[j-1])
    {
      //__llvm_pcmarker(1);
      #ifdef PROFILING
      iters_a++;
      #endif
      cnt2++;
      temp = a[j];
      a[j] = a[j-1];
      a[j-1] = temp;
      j--;
    }
    
    #ifdef PROFILING
    if ( iters_a < min_a )
      min_a = iters_a;
    if ( iters_a > max_a )
      max_a = iters_a;
    #endif
 #ifdef PRINT_RESULTS
	printf("insertsort: Inner Loop Counts: %d\n", cnt2);
#endif   
    i++;
  }

  #ifdef PROFILING
  if ( iters_i < min_i )
    min_i = iters_i;
  if ( iters_i > max_i )
    max_i = iters_i;
  #endif

  #ifdef PROFILING
  printf( "i-loop: [%d, %d]\n", min_i, max_i );
  printf( "a-loop: [%d, %d]\n", min_a, max_a );
  #endif

#ifdef PRINT_RESULTS
  printf("insertsort: Outer Loop : %d ,  Inner Loop : %d\n", cnt1, cnt2);
  printf("insertsort: a[5]=%d\n",a[5]);
#endif
  if(cnt1 != 9 || cnt2 != 9) return 1;
  if(a[5] != 6) return 1;  
  return 0;
}
