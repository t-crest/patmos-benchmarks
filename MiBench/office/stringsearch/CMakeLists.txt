add_executable(search_small bmhasrch.c  bmhisrch.c  bmhsrch.c  pbmsrch_small.c)
add_executable(search_large bmhasrch.c  bmhisrch.c  bmhsrch.c  pbmsrch_large.c)

run_io(mibench-search_small ${CMAKE_CURRENT_BINARY_DIR}/search_small
        -
        output_small.txt
        ${PROJECT_SOURCE_DIR}/MiBench/office/stringsearch/ref_output_small.txt)

run_io(mibench-search_large ${CMAKE_CURRENT_BINARY_DIR}/search_large
        -
        output_large.txt
        ${PROJECT_SOURCE_DIR}/MiBench/office/stringsearch/ref_output_large.txt)
