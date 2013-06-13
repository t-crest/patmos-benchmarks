add_executable(erijndael aes.c eaesxam.c)
add_executable(drijndael aes.c daesxam.c)

if(IS_BIGENDIAN)
  add_definitions(-DINTERNAL_BYTE_ORDER=1 -DEXTERNAL_BYTE_ORDER=1)
else()
  add_definitions(-DINTERNAL_BYTE_ORDER=2 -DEXTERNAL_BYTE_ORDER=2)
endif()

run_io(mibench-erijndael ${CMAKE_CURRENT_BINARY_DIR}/erijndael
        ${PROJECT_SOURCE_DIR}/MiBench/security/rijndael/input_small.asc
        output_small.enc
        ${PROJECT_SOURCE_DIR}/MiBench/security/rijndael/ref_output_small.enc)

run_io(mibench-drijndael ${CMAKE_CURRENT_BINARY_DIR}/drijndael
        ${PROJECT_SOURCE_DIR}/MiBench/security/rijndael/input_small.enc
        output_small.asc
        ${PROJECT_SOURCE_DIR}/MiBench/security/rijndael/ref_output_small.asc)

