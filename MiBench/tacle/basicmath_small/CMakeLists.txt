add_executable(basicmath_small basicmath_small.c   rad2deg.c  cubic.c   isqrt.c  memcpy.c  wcclibm.c)

# target_link_libraries(basicmath_small m)

run_io(tacle-mibench-basicmath_small ${CMAKE_CURRENT_BINARY_DIR}/basicmath_small "" "" "")

# Takes nearly one hour on the simulator
#run_io(mibench-basicmath_small ${CMAKE_CURRENT_BINARY_DIR}/basicmath_small
#	-
#        output_small.txt
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.txt)
# Takes a very, *very* long time
#run_io(mibench-basicmath_small ${CMAKE_CURRENT_BINARY_DIR}/basicmath_large
#	-
#        output_large.txt
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_large.txt)
