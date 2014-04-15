/*
 * Changes:
 * AJ 2014/04/15: Merged patmos/bench changes (PRINT_RESULTS, return check)
 * CS 2006/05/19: Changed loop bound from constant to variable.
 */

#ifdef PRINT_RESULTS
#include <stdio.h>
#endif

int fac (int n)
{
  if (n == 0)
     return 1;
  else
     return (n * fac (n-1));
}

int main (void)
{
  int i;
  int s = 0;
  volatile int n;

  n = 5;

  _Pragma("loopbound min 6 max 6")
  for (i = 0;  i <= n; i++) {
      _Pragma( "marker recursivecall" );
      s += fac (i);
      _Pragma( "flowrestriction 1*fac <= 6*recursivecall" );
  }

#ifdef PRINT_RESULTS
  printf("fac: s = %d\n", s);
#endif
  if (s != 154) return (1);
  return (0);
}

