add_executable(rtems_hello test.c)


# XXX method cache size too small with default options
set( PASIM_OPTIONS "")

run_io(rtems_hello ${CMAKE_CURRENT_BINARY_DIR}/rtems_hello
        -
        output.txt
        "")

