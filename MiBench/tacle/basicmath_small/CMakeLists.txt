add_executable(basicmath_small basicmath_small.c   rad2deg.c  cubic.c   isqrt.c  memcpy.c  wcclibm.c)

# target_link_libraries(basicmath_small m)

run_io(tacle-mibench-basicmath_small ${CMAKE_CURRENT_BINARY_DIR}/basicmath_small "" "" "")

run_wcet(tacle-mibench_platin-basicmath_small
         ${CMAKE_CURRENT_BINARY_DIR}/basicmath_small
         ${CMAKE_CURRENT_BINARY_DIR}/tacle-mibench-basicmath_small-wcet.txt
         360
         16 # needs high factor because we do not use trace facts
         main)

