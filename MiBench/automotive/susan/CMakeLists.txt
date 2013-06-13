add_executable(ssusan susan.c)
add_executable(esusan susan.c)
add_executable(csusan susan.c)

target_link_libraries(ssusan m)
target_link_libraries(esusan m)
target_link_libraries(csusan m)

set_target_properties(ssusan PROPERTIES COMPILE_DEFINITIONS DEFAULT_MODE=0)
set_target_properties(esusan PROPERTIES COMPILE_DEFINITIONS DEFAULT_MODE=1)
set_target_properties(csusan PROPERTIES COMPILE_DEFINITIONS DEFAULT_MODE=2)

run_io(mibench-ssusan_small ${CMAKE_CURRENT_BINARY_DIR}/ssusan
	${CMAKE_CURRENT_SOURCE_DIR}/input_small.pgm
        output_small.smoothing.pgm
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.smoothing.pgm)
run_io(mibench-esusan_small ${CMAKE_CURRENT_BINARY_DIR}/esusan
	${CMAKE_CURRENT_SOURCE_DIR}/input_small.pgm
        output_small.edges.pgm
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.edges.pgm)
run_io(mibench-csusan_small ${CMAKE_CURRENT_BINARY_DIR}/csusan
	${CMAKE_CURRENT_SOURCE_DIR}/input_small.pgm
        output_small.corners.pgm
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.corners.pgm)

# Takes too long
#run_io(mibench-ssusan_large ${CMAKE_CURRENT_BINARY_DIR}/ssusan
#	${CMAKE_CURRENT_SOURCE_DIR}/input_large.pgm
#        output_large.smoothing.pgm
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_large.smoothing.pgm)
#run_io(mibench-esusan_large ${CMAKE_CURRENT_BINARY_DIR}/esusan
#	${CMAKE_CURRENT_SOURCE_DIR}/input_large.pgm
#        output_large.edges.pgm
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_large.edges.pgm)
#run_io(mibench-csusan_large ${CMAKE_CURRENT_BINARY_DIR}/csusan
#	${CMAKE_CURRENT_SOURCE_DIR}/input_large.pgm
#        output_large.corners.pgm
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_large.corners.pgm)


