FILE1 = basicmath_small.c   rad2deg.c  cubic.c   isqrt.c
FILE2 = basicmath_large.c   rad2deg.c  cubic.c   isqrt.c
FILE3 = basicmath_tiny.c   rad2deg.c  cubic.c   isqrt.c

all: basicmath_small basicmath_large basicmath_tiny

basicmath_small: ${FILE1} Makefile
	gcc -static -O3 ${FILE1} -o basicmath_small -lm
basicmath_large: ${FILE2} Makefile
	gcc -static -O3 ${FILE2} -o basicmath_large -lm
basicmath_tiny: ${FILE3} Makefile
	gcc -static -O3 ${FILE3} -o basicmath_tiny -lm

clean:
	rm -rf basicmath_small basicmath_large basicmath_tiny output*
