add_executable(dijkstra dijkstra.c input.c)

run_io(tacle-mibench-dijkstra ${CMAKE_CURRENT_BINARY_DIR}/dijkstra "" "" "")

use_source_flowfacts(tacle-mibench_platin-dijkstra)

run_wcet(tacle-mibench_platin-dijkstra
         ${CMAKE_CURRENT_BINARY_DIR}/dijkstra
         ${CMAKE_CURRENT_BINARY_DIR}/tacle-mibench-dijkstra-wcet.txt
         720
         130 # needs high factor because we do not use trace facts
         main)
