add_executable(rawcaudio rawcaudio.c adpcm.c)
add_executable(rawdaudio rawdaudio.c adpcm.c)

if(IS_BIGENDIAN)
  run_io(mibench-rawcaudio ${CMAKE_CURRENT_BINARY_DIR}/rawcaudio
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/be_small.pcm
         output_small.adpcm 
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/ref_small.adpcm)

  run_io(mibench-rawdaudio ${CMAKE_CURRENT_BINARY_DIR}/rawdaudio
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/small.adpcm
         output_small.pcm
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/ref_be_small.pcm)
else()
  run_io(mibench-rawcaudio ${CMAKE_CURRENT_BINARY_DIR}/rawcaudio
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/le_small.pcm
         output_small.adpcm
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/ref_small.adpcm)

  run_io(mibench-rawdaudio ${CMAKE_CURRENT_BINARY_DIR}/rawdaudio
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/small.adpcm
         output_small.pcm
         ${PROJECT_SOURCE_DIR}/MiBench/telecomm/adpcm/data/ref_le_small.pcm)
endif()
