add_executable(patricia patricia.c patricia_test.c)

run_io(mibench-patricia ${CMAKE_CURRENT_BINARY_DIR}/patricia
        ${PROJECT_SOURCE_DIR}/MiBench/network/patricia/input_small.udp
        output_small.txt
        ${PROJECT_SOURCE_DIR}/MiBench/network/patricia/ref_output_small.txt)
set_tests_properties(mibench-patricia PROPERTIES WILL_FAIL "true")
