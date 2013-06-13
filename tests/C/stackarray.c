#include <stdio.h>

int main() {
    double volatile x[3] = { 2.0, 6.0, 2.5 };
    int cnt = 2;

    double volatile f = 4.0f;
    printf(" %f", f);

    for (int i = 0; i < cnt; i++) {
	printf(" %f", x[i]);
    }

    printf("\n");
    return 0;
}
