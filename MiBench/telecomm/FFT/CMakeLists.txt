add_executable(fft main.c fftmisc.c fourierf.c)
target_link_libraries(fft m)

run_io(mibench-fft_tiny ${CMAKE_CURRENT_BINARY_DIR}/fft
        ${CMAKE_CURRENT_SOURCE_DIR}/input_tiny.txt
        output_tiny.txt
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_tiny.txt)
run_io(mibench-ifft_tiny ${CMAKE_CURRENT_BINARY_DIR}/fft
        ${CMAKE_CURRENT_SOURCE_DIR}/input_tiny.inv.txt
        output_tiny.inv.txt
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_tiny.inv.txt)

# Takes too long
#run_io(mibench-fft_small ${CMAKE_CURRENT_BINARY_DIR}/fft
#        ${CMAKE_CURRENT_SOURCE_DIR}/input_small.txt
#        output_small.txt
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.txt)
#run_io(mibench-ifft_small ${CMAKE_CURRENT_BINARY_DIR}/fft
#        ${CMAKE_CURRENT_SOURCE_DIR}/input_small.inv.txt
#        output_small.inv.txt
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.inv.txt)

