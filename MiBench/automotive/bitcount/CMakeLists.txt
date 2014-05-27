add_executable(bitcnts bitcnt_1.c bitcnt_2.c bitcnt_3.c bitcnt_4.c bitcnts.c
                       bitfiles.c bitstrng.c bstr_i.c)

run_io(mibench-bitcnts ${CMAKE_CURRENT_BINARY_DIR}/bitcnts
        -
        output_small.txt
        ${PROJECT_SOURCE_DIR}/MiBench/automotive/bitcount/ref_output_small.txt)

# test whether the machine call graph has been properly constructed in the
# presence of calls-via-pointers, by checking if the ntbl_bitcount function
# made it into the PML:
add_test(NAME mibench-bitcnts-mcgcheck COMMAND grep ntbl_bitcount bitcnts.pml)
