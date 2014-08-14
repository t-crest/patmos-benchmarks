/* MDH WCET BENCHMARK SUITE.
 * Benchmark: fac
 * File: fac.c
 * Version: 1.1
 */

/* Changes: JG 2005/12/23: Inserted prototype.
 *                         Indented program.
 */
int
fac(int n)
{
	if (n == 0)
		return 1;
	else
		return (n * fac(n - 1));
}


int
fac_sum(int n)
{
	int i;
	int s = 0;
	for (i = 0; i <= n; i++)
		s += fac(i);
	return s;
}

__attribute__((noinline))
int
main_test(int n, int maxn)
{
  if(n > maxn) return -1;
  return fac_sum(n);
}
