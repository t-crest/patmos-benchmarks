

set(simpletests jumptable printf printf_long smallarray stackarray static vaargs setjmp coop uart alloca iotest setcc)

foreach(test ${simpletests})
    add_executable(${test} ${test}.c)

    run_io(tests-${test} ${CMAKE_CURRENT_BINARY_DIR}/${test}
           -
           output_${test}.txt
           ${TESTS_DATADIR}/ref_${test}.txt)

endforeach()

