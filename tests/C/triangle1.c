/* Test case for triangle loop bounds
   Set 1: simple constant loops and triangle loops with constant loop bound for outer loop */

#define TESTS 5
#include <stdint.h>
volatile int outer[TESTS],middle[TESTS],inner[TESTS];
#define F(n,T) __attribute__((noinline)) void f##n(T ub) { \
  const int X = n;

/* Test 0: simple loop (signed) */
F(0,int)
  int16_t i;
  for(i = 4; i < 134; i++) {
    outer[X]++;
  }
}

/* Test 1: simple loop (unsigned) */
F(1, int)
  uint16_t i;
  for(i = 4; i < 134; i++) {
    outer[X]++;
  }
}

/* Test 2: simple loop (step 3) */
/* !! => LLVM fails at the moment */
F(2, int)
  int16_t i;
  for(i = 27; i < 413; i+=2) {
    outer[X]++;
  }
}

/* Test 3: simple triangle loop with constant outer-loop bound */
F(3, int)
  int16_t i,j;
  for(i = 4; i < 71; i++) {
    outer[X]++;
    // bitcode CH: {-1,+,1}[0..ub+1)
    // for 0,1,2,3,4,5,6,7
    // =>  0,0,1,3,6,10,15,21
    for(j = 1; j < i; j++) {
      inner[X]++;
    }
  }
}

/* Test 4: simple triangle loop with constant outer-loop bound and 2-step outer-loop increment */
/* !! => LLVM fails at the moment */
F(4, int)
  int16_t i,j;
  for(i = 0; i < 131; i+=2) {
    outer[X]++;
    for(j = 1; j < i; j++) {
      inner[X]++;
    }
  }
}


#ifdef PRINT_RESULTS
#include <stdio.h>
#endif
#define CALLSITES 8
#define DEF_RUN(X) __attribute__((noinline)) void run_f##X() { f##X(7);f##X(6); }
DEF_RUN(0)
DEF_RUN(1)
DEF_RUN(2)
DEF_RUN(3)
DEF_RUN(4)
int main() {
  run_f0();
  run_f1();
  /* Disabled; no loopbound from LLVM */
  /* run_f2(); */
  run_f3();
  /* Disabled; no loopbound from LLVM */
  /* run_f4(); */
#ifdef PRINT_RESULTS
  int i;
  for(i = 0; i < TESTS; i++)
    printf("[%d] outer: %d, middle: %d, inner: %d\n",i,outer[i],middle[i],inner[i]);
#endif
  return 0;
}
