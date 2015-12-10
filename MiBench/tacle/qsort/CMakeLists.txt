add_executable(qsort input.c  qsort.c  wcclibm.c  wccstdlib.c)

run_io(mibench-qsort ${CMAKE_CURRENT_BINARY_DIR}/qsort "" "" "")
