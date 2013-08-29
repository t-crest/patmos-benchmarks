/* Test case for triangle loop bounds
   Set 3: deeply nested and independent middle loops */

#define TESTS 2
#include <stdint.h>
volatile int outer[TESTS],middle[TESTS],inner[TESTS];
#define F(n,T) __attribute__((noinline)) void f##n(T ub) { \
  const int X = n;

/* Test 1: independent middle loop */
F(0,uint16_t)
  uint16_t i,j,k;
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

/* Test 1: 3-level triangle loop */
F(1,uint16_t)
  uint16_t i,j,k;
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
#define RUN(x) f0(x);f1(x)
static const int callsites = 8;
int main() {
  RUN(0);
  RUN(1);
  RUN(2);
  RUN(3);
  RUN(4);
  RUN(5);
  RUN(6);
  RUN(7);
#ifdef PRINT_RESULTS
  int i;
  for(i = 0; i < TESTS; i++)
    printf("[%d] outer: %d, middle: %d, inner: %d\n",i,outer[i],middle[i],inner[i]);
#endif
  return 0;
}
