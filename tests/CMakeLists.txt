
set(TESTS_SRCDIR  ${CMAKE_CURRENT_SOURCE_DIR})
set(TESTS_DATADIR ${CMAKE_CURRENT_SOURCE_DIR}/data)

add_subdirectory(C)

if(${CMAKE_SYSTEM_NAME} MATCHES "rtems")
  add_subdirectory(RTEMS)
endif()
