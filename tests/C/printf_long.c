
#include<stdio.h>

int main() {
  unsigned long long u = 1;
  float f = 2.0f;
  double d = 6.0;

  printf("ULL 4x1: %lld %lld %lld %lld\n", u, u, u, u);

  printf("float 2.0, double 6.0: %f, %f\n", f, d);

  return 0;
}
