#include <machine/spm.h>
#include <machine/patmos.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>

int main(int argc, char** argv) {
    volatile _SPM unsigned *p = (_SPM unsigned*)0xf0000900;
    for (int i = 0; i < 3; i++) {
	for (int j = 0; j < 32; j++) {
	unsigned leds = 0;
	    leds |= (1 << j);
	    *p = leds;
	}
    }
    clock_t c = clock();
    //printf("CPU-ID: %d, clock: %llu\n", get_cpuid(), c);
    clock_t c2 = clock();
    struct timeval tv;
    gettimeofday(&tv, 0);
    //printf("clock2: %llu, usecs: %lu, secs: %llu\n", c2, tv.tv_usec, tv.tv_sec);
    return 0;
}
