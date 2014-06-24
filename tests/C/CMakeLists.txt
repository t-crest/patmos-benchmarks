

set(simpletests jumptable printf printf_long smallarray stackarray static vaargs setjmp coop uart alloca iotest setcc triangle1 triangle2 triangle3)

foreach(test ${simpletests})
    add_executable(${test} ${test}.c)
    if(NOT ${BUILD_WCET_ANALYSIS})
        set_target_properties(${test} PROPERTIES COMPILE_FLAGS "-DPRINT_RESULTS")
    endif()
    run_io(tests-${test} ${CMAKE_CURRENT_BINARY_DIR}/${test}
           -
           output_${test}.txt
           ${TESTS_DATADIR}/ref_${test}.txt)
endforeach()

