set(REQUIRES_PASIM true)

project(patmos-benchmarks)

cmake_minimum_required(VERSION 2.8)

# we are only using C at the moment
enable_language(C)

# enable testing using ctest
if(ENABLE_TESTING)
  # Target-dependent macros for testing:
  #     macro (run_io name prog in out ref)
  enable_testing()
endif()

# global configuration options
if("${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
  set(IS_BIGENDIAN true)
endif()

# check for the a3 tool.
message(STATUS "Checking for a3 (${CMAKE_SYSTEM_PROCESSOR}).")
find_program(A3_EXECUTABLE NAMES a3${CMAKE_SYSTEM_PROCESSOR} a3${CMAKE_SYSTEM_NAME} DOC "Path to the a3 WCET analysis tool.")
if(NOT A3_EXECUTABLE)
  message(WARNING "a3 not found (${CMAKE_SYSTEM_PROCESSOR}).")
endif()

# add benchmark sub-directories
add_subdirectory(PapaBench-0.4)
add_subdirectory(Mediabench)
add_subdirectory(MiBench)
add_subdirectory(Malardalen)
add_subdirectory(tests)

# add timing analysis sub-directory
if(A3_EXECUTABLE)
  add_subdirectory(a3)
endif()
