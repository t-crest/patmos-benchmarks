add_executable(basicmath_tiny  basicmath_tiny.c    rad2deg.c  cubic.c   isqrt.c)
add_executable(basicmath_small basicmath_small.c   rad2deg.c  cubic.c   isqrt.c)
add_executable(basicmath_large basicmath_large.c   rad2deg.c  cubic.c   isqrt.c)

target_link_libraries(basicmath_tiny  m)
target_link_libraries(basicmath_small m)
target_link_libraries(basicmath_large m)

run_io(mibench-basicmath_tiny ${CMAKE_CURRENT_BINARY_DIR}/basicmath_tiny
	-
        output_tiny.txt
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_tiny.txt)

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
