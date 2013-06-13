add_definitions(-DFPM_DEFAULT)

add_library(libmad  STATIC version.c fixed.c bit.c timer.c stream.c 
		           frame.c synth.c decoder.c layer12.c layer3.c huffman.c)
