# MRTC Benchmarks

# Configuration
TESTFLAGS=-DTEST_PRINT_RESULTS -DTEST_PRINT_VERSION
CC=gcc
CFLAGS=-ggdb

BENCHMARKS := bsort100 bs cnt compress cover crc expint fac fdct

HOST_BINARIES = $(BENCHMARKS:%=%.bin)
PATMOS_BINARIES = $(BENCHMARKS:%=%.elf)

BINARIES = $(HOST_BINARIES) $(PATMOS_BINARIES)

.PHONY: all clean patmos

all: $(BINARIES)

%.elf: CC=patmos-clang
%.elf: CFLAGS=-g

%.bin: %-test.c %.c
	$(CC) $(CFLAGS) $(TESTFLAGS) -o $@ $^

%.elf: %-test.c %.c
	$(CC) $(CFLAGS) $(TESTFLAGS) -o $@ $^
clean:
	rm -f $(BINARIES)


