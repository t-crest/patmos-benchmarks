# MRTC Benchmarks

# Configuration
TESTFLAGS=-DTEST_PRINT_RESULTS -DTEST_PRINT_VERSION
CC=gcc
CFLAGS=-g

BENCHMARKS=bs cnt fac

all: $(BENCHMARKS)

fac: fac-test.c fac.o
	$(CC) $(CFLAGS) $(TESTFLAGS) -o $@ $^
bs: bs-test.c bs.o
	$(CC) $(CFLAGS) $(TESTFLAGS) -o $@ $^
cnt: cnt-test.c cnt.o
	$(CC) $(CFLAGS) $(TESTFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

clean:
	rm -f *.o $(BENCHMARKS)
