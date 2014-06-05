# add sub-directories
if("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "patmos")
  add_subdirectory("patmos/clang")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/patmos/clang/)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "leon3")
  add_subdirectory("sparc/gcc")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/sparc/gcc/)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "mpc5554")
  add_subdirectory("mpc5554/gcc")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/mpc5554/gcc/)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm7")
  add_subdirectory("arm7-lpc2138-mam/gcc-if07")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/arm7-lpc2138-mam/gcc-if07/)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86")
  add_subdirectory("intel/linux")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/intel/linux/)
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "x86-64")
  add_subdirectory("intel/linux")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/intel/linux/)
else()
  message(FATAL_ERROR "Unknown processor platform for Debie1-e: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/harness)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_executable(debie1 class.c classtab.c debie.c health.c hw_if.c measure.c
                      tc_hand.c telem.c harness/harness.c)

run_io(debie1-harness ${CMAKE_CURRENT_BINARY_DIR}/debie1
  -
  output.txt
  ${CMAKE_CURRENT_SOURCE_DIR}/ref.txt)

# enable some printfs and exit main() for test comparison
add_definitions(-DPATMOS_TEST)

target_link_libraries(debie1 debie1-target)

