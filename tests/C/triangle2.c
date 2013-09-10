/* Test case for triangle loop bounds
   Set 2: simple symbolic bounds depending on the only argument; triangle loops depnding on a symbolic outer loop bound */
#define TESTS 5
#include <stdint.h>
volatile int outer[TESTS],middle[TESTS],inner[TESTS];
#define F(n,T) __attribute__((noinline)) void f##n(T ub) { \
  const int X = n;

/* Test 0: simple loop with symbolic bound (signed) */
F(0,int16_t)
  int16_t i;
  for(i = -1; i < ub; i++) {
    outer[X]++;
  }
}

/* Test 1: simple loop with symbolic bound (unsigned) */
F(1, uint16_t)
  uint16_t i;
  for(i = 0; i < ub+1; i++) {
    outer[X]++;
  }
}

/* Test 2: simple triangle loop with symbolic outer-loop bound */
F(2, int)
  int i,j;
  for(i = 0; i < ub+1; i++) {
    outer[X]++;
    // bitcode CH: {-1,+,1}[0..ub+1)
    // for 0,1,2,3,4,5,6,7
    // =>  0,0,1,3,6,10,15,21
    for(j = 1; j < i; j++) {
      inner[X]++;
    }
  }
}

/* test 3: upper-triangle loop with symbolic outer bound */
F(3,int)
  int i,j;
  for(i = 0; i < ub+1; i++) {
    outer[X]++;
    // bitcode CH: {(-4 + %ub),+,-1}[0..ub+1)
    // for 0,1,2,3,4,5,6,7
    //  => 0,0,0,0,0,1,3,6
    for(j = i+1; j <= ub-4; j++) {
      inner[X]++;
    }
  }
}

/* test 4: down-counting triangle loop with symbolic outer bound */
F(4, int)
  int i,j;
  for(i = 0; i < ub+1; i++) {
    outer[X]++;
    // for 0,1,2, 3, 4, 5, 6, 7
    //  => 8,9,10,11,12,13,14,15
    for(j = ub+4; j >= i-3; j--) {
      inner[X]++;
    }
  }
}



#ifdef PRINT_RESULTS
#include <stdio.h>
#endif
#define CALLSITES 8
#define DEF_RUN(X) __attribute__((noinline)) void run_f##X() { \
                   f##X(0);f##X(1);f##X(5);f##X(4);f##X(3);f##X(2);f##X(7);f##X(6); }
DEF_RUN(0)
DEF_RUN(1)
DEF_RUN(2)
DEF_RUN(3)
DEF_RUN(4)
int main() {
  run_f0();
  /* Disabled; no loopbound from LLVM */
  /* run_f1(); */
  run_f2();
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
