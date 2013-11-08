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

# RTEMS based build (EXPERIMENTAL)
if(${TRIPLE} MATCHES "patmos-unknown-rtems")
  # add RTEMS include path
  include_directories(${RTEMS_LIBPATH}/include)

  # add RTEMS default libs (linking with -L .. -l.. does not work)
  add_library(rtemscpu STATIC IMPORTED)
  add_library(rtemsbsp STATIC IMPORTED)
  set_property(TARGET rtemscpu PROPERTY IMPORTED_LOCATION ${RTEMS_LIBPATH}/librtemscpu.a)
  set_property(TARGET rtemsbsp PROPERTY IMPORTED_LOCATION ${RTEMS_LIBPATH}/librtemsbsp.a)
  link_libraries(rtemscpu rtemsbsp)
endif()

# add benchmark sub-directories
add_subdirectory(PapaBench-0.4)
add_subdirectory(Mediabench)
add_subdirectory(MiBench)
add_subdirectory(Malardalen)
add_subdirectory(tests)

# add non-free benchmarks
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/nonfree)
  add_subdirectory(nonfree)
else()
  message("Omitting non-free benchmarks.")
endif()



set(ENABLE_CTORTURE true CACHE BOOL "Enable gcc.c-torture suite (long build time)")
set(GCC_C_TORTURE_EXECUTE_PATH ${CMAKE_CURRENT_BINARY_DIR}/gcc.c-torture/execute CACHE FILEPATH 
    "Path to the gcc.c_torture/execute checkout.")

find_package(Subversion)
if(SUBVERSION_FOUND AND ENABLE_CTORTURE)
  # add gcc.torture-execute

  # TODO: Update revision to be checked out every once in a while
  set(GCC_C_TORTURE_REPO svn://gcc.gnu.org/svn/gcc/trunk/gcc/testsuite/gcc.c-torture)
  set(GCC_C_TORTURE_REVISION 200887)

  # we only want the "execute" part of the torture tests
  execute_process(COMMAND ${Subversion_SVN_EXECUTABLE}
	checkout ${GCC_C_TORTURE_REPO}/execute -r ${GCC_C_TORTURE_REVISION}
	${GCC_C_TORTURE_EXECUTE_PATH})

  add_subdirectory(gcc.c-torture)
endif()

# add timing analysis sub-directory
if(A3_EXECUTABLE)
  add_subdirectory(a3)
endif()
