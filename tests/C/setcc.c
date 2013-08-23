#include <stdio.h>

volatile int out;

__attribute__((noinline)) 
void f(long long int x, long long int y) { 
    int i;

    // this will get lowered to i1 = setcc i1, i1, setne;
    if ((x > 0) == (y > 0)) {
	for(i = 0; i<1024;i++) out+=x;
	printf("larger\n");
    } else {
	out += 10;
	printf("smaller\n");
    }
} 

int main() { 
    f(3, 0);
    f(5, 4);
    return 0; 
}
