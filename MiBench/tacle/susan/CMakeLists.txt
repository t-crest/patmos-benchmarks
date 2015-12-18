add_executable(susan input.c  susan.c  wccfile.c wcclibm.c wccmalloc.c)

target_link_libraries(susan m)

run_io(tacle-mibench-susan ${CMAKE_CURRENT_BINARY_DIR}/susan "" "" "")

use_source_flowfacts(tacle-mibench_platin-susan)

run_wcet(tacle-mibench_platin-susan
         ${CMAKE_CURRENT_BINARY_DIR}/susan
         ${CMAKE_CURRENT_BINARY_DIR}/tacle-mibench-qsort-wcet.txt
         720
         16 # needs high factor because we do not use trace facts
         main)
