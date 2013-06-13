add_executable(crc_32 crc_32.c)

run_io(mibench-crc_32 ${CMAKE_CURRENT_BINARY_DIR}/crc_32
        ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/small.adpcm
        output_small.txt
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.txt)
