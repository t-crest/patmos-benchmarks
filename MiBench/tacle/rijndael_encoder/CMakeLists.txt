add_executable(rijndael_encoder aes.c  glibc_common.c  input_small.c  my_file.c  rijndael_encoder.c)

if(IS_BIGENDIAN)
  add_definitions(-DINTERNAL_BYTE_ORDER=1 -DEXTERNAL_BYTE_ORDER=1)
else()
  add_definitions(-DINTERNAL_BYTE_ORDER=2 -DEXTERNAL_BYTE_ORDER=2)
endif()

run_io(tacle-mibench-rijndael_encoder ${CMAKE_CURRENT_BINARY_DIR}/rijndael_encoder "" "" "")


