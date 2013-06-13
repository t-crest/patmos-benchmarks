add_executable(dijkstra_small dijkstra_small.c)

run_io(mibench-dijkstra_small ${CMAKE_CURRENT_BINARY_DIR}/dijkstra_small
        ${PROJECT_SOURCE_DIR}/MiBench/network/dijkstra/input.dat
        output_small.dat
        ${PROJECT_SOURCE_DIR}/MiBench/network/dijkstra/ref_output_small.dat)
