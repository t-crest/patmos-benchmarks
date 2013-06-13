#include <stdio.h>

void myprint(long long i) {
    printf("%X %X \n", (unsigned)(i >> 32), (unsigned)(i & 0xFFFFFFFF));
}

void myvprint(const char *s, ...) {
    va_list argp;

    va_start(argp, s);

    // get an int value
    int i = va_arg(argp, int);

    printf("%s i: %d\n", s, i);

    // get a long long value
    long long l = va_arg(argp, long long);

    myprint(l);

    // get a double (floats are always promoted to double with varargs)
    double d = va_arg(argp, double);
    int *p = (int*)&d;

    printf("d: %f %X %X\n", d, *(p++), *p);

    va_end(argp);
}

int main(int argc, char** argv) {
    const char *s;

    if (argc < 2) {
	s = "Hello World!";
    } else {
	s = "Goodbye";
    }

    myvprint(s, 8, 0x12345678ABCDl, 1.1);

    return 0;
}
