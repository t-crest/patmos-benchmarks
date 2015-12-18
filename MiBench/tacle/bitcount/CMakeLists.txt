add_executable(bitcount  bitcnt_1.c  bitcnt_2.c  bitcnt_3.c  bitcnt_4.c  bitcount.c)

run_io(tacle-mibench-bitcount ${CMAKE_CURRENT_BINARY_DIR}/bitcount "" "" "")

use_source_flowfacts(tacle-mibench_platin-bitcount)

run_wcet(tacle-mibench_platin-bitcount
         ${CMAKE_CURRENT_BINARY_DIR}/bitcount
         ${CMAKE_CURRENT_BINARY_DIR}/tacle-mibench-bitcount-wcet.txt
         360
         16 # needs high factor because we do not use trace facts
         main)

