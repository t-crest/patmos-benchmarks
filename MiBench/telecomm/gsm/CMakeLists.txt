
set(GSM_BASE ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(src)

run_io(mibench-toast_small ${CMAKE_CURRENT_BINARY_DIR}/src/toast
        ${CMAKE_CURRENT_SOURCE_DIR}/data/small.au
        output_small.encode.gsm
        ${CMAKE_CURRENT_SOURCE_DIR}/data/correct_small.au.gsm)
run_io(mibench-untoast_small ${CMAKE_CURRENT_BINARY_DIR}/src/untoast
        ${CMAKE_CURRENT_SOURCE_DIR}/data/small.au.run.gsm
        output_small.decode.run
        ${CMAKE_CURRENT_SOURCE_DIR}/data/correct_small.au.run)

#run_io(mibench-toast_large ${CMAKE_CURRENT_BINARY_DIR}/src/toast
#        ${CMAKE_CURRENT_SOURCE_DIR}/data/large.au
#        output_large.encode.gsm
#        ${CMAKE_CURRENT_SOURCE_DIR}/correct_large.au.gsm)
#run_io(mibench-untoast_large ${CMAKE_CURRENT_BINARY_DIR}/src/untoast
#        ${CMAKE_CURRENT_SOURCE_DIR}/data/large.au.run.gsm
#        output_large.decode.run
#        ${CMAKE_CURRENT_SOURCE_DIR}/correct_large.au.run)

