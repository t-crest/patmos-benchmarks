#include <alloca.h>
#include <stdio.h>

void bar(int *c, unsigned a) {

    c[a-1] = 100;

    for (int i = 0; i < a; i++) {
	printf("i %i : %i\n", i, c[i]);
    }

}

void foo(unsigned a) {

    int *c = alloca(a * 4);

    for (int i = 0; i < a; i++) {
	c[i] = i;
    }

    bar(c, a);
}

int main(int argc, char** argv) {
    volatile unsigned a = 32;

    foo(a);

    return 0;
}
