add_executable(dijkstra dijkstra.c input.c)

run_io(mibench-dijkstra ${CMAKE_CURRENT_BINARY_DIR}/dijkstra "" "" "")
