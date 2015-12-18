add_executable(qsort input.c  qsort.c  wcclibm.c  wccstdlib.c)

run_io(tacle-mibench-qsort ${CMAKE_CURRENT_BINARY_DIR}/qsort "" "" "")

use_source_flowfacts(tacle-mibench_platin-qsort)

run_wcet(tacle-mibench_platin-qsort
         ${CMAKE_CURRENT_BINARY_DIR}/qsort
         ${CMAKE_CURRENT_BINARY_DIR}/tacle-mibench-qsort-wcet.txt
         360
         16 # needs high factor because we do not use trace facts
         main)

