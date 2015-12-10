add_executable(bitcnts  bitcnt_1.c  bitcnt_2.c  bitcnt_3.c  bitcnt_4.c  bitcount.c)

run_io(mibench-bitcount ${CMAKE_CURRENT_BINARY_DIR}/bitcount "" "" "")

