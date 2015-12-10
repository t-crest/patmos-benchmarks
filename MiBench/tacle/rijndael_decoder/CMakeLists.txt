add_executable(rijndael_decoder aes.c  glibc_common.c  input_small_enc.c  my_file.c  rijndael_decoder.c)

if(IS_BIGENDIAN)
  add_definitions(-DINTERNAL_BYTE_ORDER=1 -DEXTERNAL_BYTE_ORDER=1)
else()
  add_definitions(-DINTERNAL_BYTE_ORDER=2 -DEXTERNAL_BYTE_ORDER=2)
endif()

run_io(tacle-mibench-rijndael_decoder ${CMAKE_CURRENT_BINARY_DIR}/rijndael_decoder "" "" "")


