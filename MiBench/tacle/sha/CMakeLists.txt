add_executable(sha input_small.c  memcpy.c  mem_helper.c  memset.c  my_file.c  sha.c  sha_driver.c)

run_io(mibench-sha ${CMAKE_CURRENT_BINARY_DIR}/sha "" "" "")
