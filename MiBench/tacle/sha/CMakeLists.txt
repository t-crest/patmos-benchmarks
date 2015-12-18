add_executable(sha input_small.c  memcpy.c  mem_helper.c  memset.c  my_file.c  sha.c  sha_driver.c)

run_io(mibench-sha ${CMAKE_CURRENT_BINARY_DIR}/sha "" "" "")

use_source_flowfacts(tacle-mibench_platin-sha)

run_wcet(tacle-mibench_platin-sha
         ${CMAKE_CURRENT_BINARY_DIR}/sha
         ${CMAKE_CURRENT_BINARY_DIR}/tacle-mibench-sha-wcet.txt
         360
         8 # needs high factor because we do not use trace facts
         main)

