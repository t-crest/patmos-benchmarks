add_subdirectory(jpeg-6a)

run_io(mibench-cjpeg_small ${CMAKE_CURRENT_BINARY_DIR}/jpeg-6a/cjpeg
        ${CMAKE_CURRENT_SOURCE_DIR}/input_small.ppm
        output_small_encode.jpeg
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.jpeg)
run_io(mibench-djpeg_small ${CMAKE_CURRENT_BINARY_DIR}/jpeg-6a/djpeg
        ${CMAKE_CURRENT_SOURCE_DIR}/input_small.jpg
        output_small_decode.ppm
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.ppm)

