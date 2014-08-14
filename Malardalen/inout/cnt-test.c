/* MDH WCET BENCHMARK SUITE.
 * Benchmark: cnt
 * File: cnt-test.c
 * Version: 1.4
 */
/* Compilation
 *   $(CC) $(DEFS) -o cnt.bin cnt-test.c bs.o
 * DEFS
 *   TEST_PRINT_RESULTS     ... write test result to stdout
 *   TEST_PRINT_VERSION     ... print version of benchmark
 *   TEST_NO_RUNTIME_CHECK  ... do not check test result at runtime
 */

#ifdef TEST_PRINT_VERSION
#include <stdio.h>
static void print_version()
{
    puts("cnt v1.4");
}
#endif /* TEST_PRINT_VERSION */


typedef struct {
  int postot, negtot;
  int poscnt, negcnt;
} result_t;



#ifdef TEST_PRINT_RESULTS
#include <stdio.h>
/**
 * Generate reference output.
 */
static void dump_result(int in, result_t *out)
{
  printf( "in: %d, out: { %d, %d, %d, %d }\n",
          in,
          out->postot, out->negtot, out->poscnt, out->negcnt);
}
#else /* TEST_PRINT_RESULTS */
#define dump_result(in,out) do { (void) in; } while(0)
#endif /* TEST_PRINT_RESULTS */

#ifndef TEST_NO_RUNTIME_CHECK
#define CHECK(out,ref) check((out),(ref))
static int check(result_t *out, result_t *ref)
{
  return (out->postot == ref->postot) &&
         (out->negtot == ref->negtot) &&
         (out->poscnt == ref->poscnt) &&
         (out->negcnt == ref->negcnt);
}

#else /* TEST_NO_RUNTIME_CHECK */
#define CHECK(out,ref) 1 /* ok */
#endif /* TEST_NO_RUNTIME_CHECK */

static int process_result(int in, result_t *out, result_t *ref)
{
  dump_result(in,out);
  return CHECK(out,ref);
}

/* external declarations */
extern int main_test(int in_seed);
extern int Postotal, Negtotal, Poscnt, Negcnt;


/**
 * Test cases
 */
static int       tests_in[8]  = { 0, 1, 588, 913, 1032, 3921, 5412, 8095 };
static result_t  tests_ref[8] = { 
  { 0, 396675, 0, 100 },
  { 0, 417195, 0, 100 },
  { 0, 400885, 0, 100 },
  { 0, 391510, 0, 100 },
  { 0, 429175, 0, 100 },
  { 0, 431770, 0, 100 },
  { 0, 395610, 0, 100 },
  { 0, 396675, 0, 100 }
};

static int test_case(int in, result_t *ref)
{
  result_t out;
  (void) main_test(in);
  out.postot = Postotal;
  out.negtot = Negtotal;
  out.poscnt = Poscnt;
  out.negcnt = Negcnt;
  return process_result(in, &out, ref);
}

int main(int argc, char **argv)
{
#ifdef TEST_PRINT_VERSION
  print_version();
#endif
  int ok = 1;
  int i;
  /* perform all tests */
  for(i = 0; i < sizeof(tests_in)/sizeof(tests_in[0]); i++) {
      ok &= test_case(tests_in[i], &tests_ref[i]);
  }
  /* exit code 0 if all tests succeeded, otherwise 1 */
  return (ok != 0) ? 0 : 1;
}
