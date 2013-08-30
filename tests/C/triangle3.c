/* Test case for triangle loop bounds
   Set 3: deeply nested and independent middle loops */

#define TESTS 4
#include <stdint.h>
volatile int outer[TESTS],middle[TESTS],inner[TESTS];
#define F(n,T) __attribute__((noinline)) void f##n(T ub) { \
  const int X = n;

/* Test 0: independent middle loop, constant loop bounds (no unrolling, please) */
F(0,int)
  int i,j,k;
  for(i = 0; i < 17; i++) {
    inner[X]++;
    for(j = 1; j < 19; j++) {
      middle[X]++;
      for(k = 0; k < i; k++) {
        inner[X]++;
      }
    }
  }
}

/* Test 1: independent middle loop, symbolic loop bounds */
F(1,int)
  int i,j,k;
  for(i = 0; i < ub; i++) {
    inner[X]++;
    for(j = 0; j < ub; j++) {
      middle[X]++;
      for(k = 0; k < i; k++) {
        inner[X]++;
      }
    }
  }
}

/* Test 2: 3-level triangle loop, constant loop bound */
F(2,int)
  int i,j,k;
  for(i = 0; i < 17; i++) {
    inner[X]++;
    for(j = 0; j < i; j++) {
      middle[X]++;
      for(k = 0; k < j; k++) {
        inner[X]++;
      }
    }
  }
}

/* Test 3: 3-level triangle loop, symbolic loop bound */
F(3,int)
  int i,j,k;
  for(i = 0; i < ub; i++) {
    inner[X]++;
    for(j = 0; j < i; j++) {
      middle[X]++;
      for(k = 0; k < j; k++) {
        inner[X]++;
      }
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
int main() {
  run_f0();
  run_f1();
  run_f2();
  run_f3();
#ifdef PRINT_RESULTS
  int i;
  for(i = 0; i < TESTS; i++)
    printf("[%d] outer: %d, middle: %d, inner: %d\n",i,outer[i],middle[i],inner[i]);
#endif
  return 0;
}
