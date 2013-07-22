/* MDH WCET BENCHMARK SUITE. File version $Id: minmax.c,v 1.1 2005/11/11 10:18:31 ael01 Exp $ */


 /*
  * Changes: JG 2005/12/23: Changed type of main to int, added prototypes.
                            Indented program.
  */
#ifdef PRINT_RESULTS
#include <stdio.h>
#endif
void            swap(int *a, int *b);
int             min(int a, int b, int c);
int             max(int a, int b, int c);

__attribute__((noninline))
void
swap(int *a, int *b)
{
	int             tmp = *a;
	*a = *b;
	*b = tmp;
}

int
min(int a, int b, int c)
{
	int             m;
	if (a <= b) {
		if (a <= c)
			m = a;
		else
			m = c;
	} else
		m = (b <= c) ? b : c;
	return m;
}

int
max(int a, int b, int c)
{
	if (a <= b)
		swap(&a, &b);
	if (a <= c)
		swap(&a, &c);
	return a;
}

volatile int xi = 10;
volatile int yi = 2;
volatile int zi = 1;
int
main(void)
{
	int             x = xi;
	int             y = yi;
	int             z = zi;
        int             r;
	if (x <= y)
		swap(&x, &y);
	else if (x <= z)
		x += min(x, y, z);
	else
		z *= max(z, y, x);
        r = (y <= z ? y + z : y - z);
#ifdef PRINT_RESULTS
        printf("minmax: r=%d\n",r);
#endif
        if(r != 12) return 1;
	return 0;
}
