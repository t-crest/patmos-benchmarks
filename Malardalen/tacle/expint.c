/************************************************************************
 * 
 * DESCRIPTION: Series expansion for computing an exponential integral
 * 		function.  
 *
 * COMMENTS: Inner loop that only runs once, structural WCET estimate 
 * 	     gives heavy overestimate.	
 * 
 * FROM: http://sron9907.sron.nl/manual/numrecip/c/expint.c
 *
 * FEATURE: One loop depends on a loop-invariant value to determine
 *   	    if it run or not.
 *
 ***********************************************************************/

 /*
  * Changes:
  * AJ 2014/04/15: Merged patmos/bench changes (PRINT_RESULTS, return check)
  */

#ifdef PRINT_RESULTS
#include <stdio.h>
#endif

/* Forward function prototypes */
long int expint(int n, long int x);


int main( void )
{
  long int r = expint(50,1);
  /* with  expint(50,21) as argument, runs the short path
   in expint.   expint(50,1)  gives the longest execution time */
#ifdef PRINT_RESULTS
  printf("expint: r = %ld\n", r);
#endif
  if(r != 3883) return 1;
  return 0;
}


long int foo( long int x )
{
  return ( x*x+(8*x) ) << ( 4-x );
}


/* Function with same flow, different data types,
   nonsensical calculations */
long int expint( int n, long int x )
{
  int      i,ii,nm1;
  long int a,b,c,d,del,fact,h,psi,ans;

  nm1=n-1;                      /* arg=50 --> 49 */

  if(x>1)                       /* take this leg? */
  {
    b= x+n;
    c= 0x2e6;
    d= 0x3e7;
    h= 0xd;

    _Pragma("loopbound min 100 max 100")
    for (i=1;i<=100;i++)      /* MAXIT is 100 */
    {
      a = -i*(nm1+i);
      b += 2;
      d=10*(a*d+b);
      c=b+a/c;
      del=c*d;
      h *= del;
      if (del < 10000)
      {
	ans=h*-x;
	return ans;
      }
    }
  }
  else                          /* or this leg? */
  {
    /* For the current argument, will always take
       '2' path here: */
    ans = nm1 != 0 ? 2 : 1000;
    fact=1;
    //__llvm_pcmarker(0);
    _Pragma("loopbound min 100 max 100")
    for (i=1;i<=100;i++)      /* MAXIT */
    {
      //__llvm_pcmarker(1);
      fact *= -x/i;
      if (i != nm1) {         /* depends on parameter n */
	del = -fact/(i-nm1);
      }
      else                  /* this fat piece only runs ONCE */
      {                   /* runs on iter 49 */
	psi = 0x00FF;
	_Pragma("loopbound min 49 max 49")
	for (ii=1;ii<=nm1;ii++) { /*  */
	  psi += ii + nm1;
	}
	del=psi+fact*foo(x);
      }
      ans += del;
      /* conditional leave removed */
    }
  }
  return ans;
}

