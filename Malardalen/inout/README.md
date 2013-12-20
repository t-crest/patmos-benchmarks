# Multi-Path Malardalen Benchmarks

This is the multi-path version of the Malardalen WCET benchmark suite.
In contrast to the original benchmark suite, it provides a set of test runs
for each benchmark kernel.

* In the original source, main is changed to main_test, which takes inputs and should be analyzed.
  The code is adapted to behave differently depending on the input.
* The file NAME-test.c contains test cases and the test driver

## Notes

cover: control flow does not depend on input at all
edn:   control flow does not depend on input at all

## Bug Fixes

compress: Choosing a small table size (HSIZE) of 257 when using 16 bits (original MDH benchmarks) is wrong.
          It leads to segmentation faults for certain test cases; moreover, a table with less than 258 entries
	  is pointless, as there is no space to do any compression in this case.
	  Fixed by setting BITS to 9 and HSIZE to 691 (still small enough for microprocessors).

## How to run tests

```
    # set benchmark
    M=bs

    # run on host
    gcc -ggdb -o ${M}-test.bin ${M}.c ${M}-test.c -DTEST_PRINT_RESULTS=1
    ./${M}-test.bin

    # run on target
    patmos-clang -O1 -Xopt --disable-inlining -o ${M}-test.elf ${M}-test.c ${M}.c
    pasim ${M}-test.elf
```
