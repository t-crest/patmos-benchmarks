add_executable(qsort_small qsort_small.c)

run_io(mibench-qsort_small ${CMAKE_CURRENT_BINARY_DIR}/qsort_small
        ${PROJECT_SOURCE_DIR}/MiBench/automotive/qsort/input_small.dat
        output_small.txt
        ${PROJECT_SOURCE_DIR}/MiBench/automotive/qsort/ref_output_small.txt)
