add_executable(sha sha_driver.c sha.c)

run_io(mibench-sha ${CMAKE_CURRENT_BINARY_DIR}/sha
        ${PROJECT_SOURCE_DIR}/MiBench/security/sha/input_small.asc
        output_small.enc
        ${PROJECT_SOURCE_DIR}/MiBench/security/sha/ref_output_small.enc)
