
set(GSM_BASE ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(src)

run_io(mibench-toast_small ${CMAKE_CURRENT_BINARY_DIR}/src/toast
        ${CMAKE_CURRENT_SOURCE_DIR}/data/clinton.pcm
        output.encode.gsm
        ${CMAKE_CURRENT_SOURCE_DIR}/data/clinton.pcm.gsm)
run_io(mibench-untoast_small ${CMAKE_CURRENT_BINARY_DIR}/src/untoast
        ${CMAKE_CURRENT_SOURCE_DIR}/data/clinton.pcm.run.gsm
        output.decode.run
        ${CMAKE_CURRENT_SOURCE_DIR}/data/clinton.pcm.run)

