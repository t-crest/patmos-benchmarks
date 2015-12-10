add_executable(susan input.c  susan.c  wccfile.c  wcclibm.c  wccmalloc.c)

target_link_libraries(susan m)

run_io(mibench-susan ${CMAKE_CURRENT_BINARY_DIR}/susan "" "" "")

