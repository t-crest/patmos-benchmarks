# MRTC Benchmarks

# Configuration
TESTFLAGS=-DTEST_PRINT_RESULTS -DTEST_PRINT_VERSION
CC=gcc
CFLAGS=-ggdb

BENCHMARKS := bsort100 bs cnt compress cover crc expint fac fdct

BINARIES = $(BENCHMARKS:%=%.bin)


.PHONY: all clean patmos

all: $(BINARIES)

patmos: CC=patmos-clang
patmos: CFLAGS=-g
patmos: $(BINARIES)

%.bin: %-test.c %.c
	$(CC) $(CFLAGS) $(TESTFLAGS) -o $@ $^

clean:
	rm -f $(BINARIES)


