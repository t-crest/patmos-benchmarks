INCLUDE(CMakeForceCompiler)

# this one is important
SET(CMAKE_SYSTEM_NAME patmos)
SET(CMAKE_SYSTEM_PROCESSOR patmos)

SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find clang for cross compiling
find_program(CLANG_EXECUTABLE NAMES patmos-clang clang DOC "Path to the clang front-end.")

if(NOT CLANG_EXECUTABLE)
  message(FATAL_ERROR "clang required for a Patmos build.")
endif()

# read the env var for patmos gold
if(NOT PATMOS_GOLD)
    set(PATMOS_GOLD $ENV{PATMOS_GOLD})
endif()
find_program(PATMOS_GOLD NAMES patmos-gold patmos-ld DOC "Path to the Patmos ELF linker.")

if( PATMOS_GOLD )
  set( PATMOS_GOLD_ENV "/usr/bin/env PATMOS_GOLD=${PATMOS_GOLD} " )
  #set( ENV{PATMOS_GOLD} ${PATMOS_GOLD_BIN} )
endif( PATMOS_GOLD )


CMAKE_FORCE_C_COMPILER(  ${CLANG_EXECUTABLE} GNU)
CMAKE_FORCE_CXX_COMPILER(${CLANG_EXECUTABLE} GNU)

# the clang triple, also used for installation
set(TRIPLE "patmos-unknown-unknown-elf" CACHE STRING "Target triple to compile compiler-rt for.")

# set some compiler-related variables;
set(CMAKE_C_COMPILE_OBJECT   "<CMAKE_C_COMPILER>   -target ${TRIPLE} -fno-builtin -emit-llvm <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>")
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> -target ${TRIPLE} -fno-builtin -emit-llvm <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>")
set(CMAKE_C_LINK_EXECUTABLE  "${PATMOS_GOLD_ENV}<CMAKE_C_COMPILER> -target ${TRIPLE} -fno-builtin <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> -mpreemit-bitcode=<TARGET>.bc -mserialize=<TARGET>.pml <LINK_LIBRARIES>")
set(CMAKE_FORCE_C_OUTPUT_EXTENSION ".bc" FORCE)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-config
find_program(LLVM_CONFIG_EXECUTABLE NAMES patmos-llvm-config llvm-config DOC "Path to the llvm-config tool.")

if(NOT LLVM_CONFIG_EXECUTABLE)
  message(FATAL_ERROR "LLVM required for a Patmos build.")
endif()

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --targets-built
                OUTPUT_VARIABLE LLVM_TARGETS
                OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT (${LLVM_TARGETS} MATCHES "Patmos"))
  message(FATAL_ERROR "llvm-config '${LLVM_CONFIG_EXECUTABLE}' does not report 'Patmos' as supported target.")
endif()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find ar (use gold ar with LTO plugin (patmos-ar) if available; llvm-ar does not work)
find_program(LLVM_AR_EXECUTABLE NAMES patmos-ar ar DOC "Path to the ar tool.")

if(NOT LLVM_AR_EXECUTABLE)
  message(FATAL_ERROR "llvm-ar required for a Patmos build.")
endif()


set(CMAKE_AR ${LLVM_AR_EXECUTABLE} CACHE FILEPATH "Archiver")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-as
find_program(LLVM_AS_EXECUTABLE NAMES patmos-llvm-as llvm-as DOC "Path to the llvm-as tool.")

if(NOT LLVM_AS_EXECUTABLE)
  message(FATAL_ERROR "llvm-as required for a Patmos build.")
endif()

set(CMAKE_AS ${LLVM_AS_EXECUTABLE} CACHE FILEPATH "LLVM assembler")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ranlib
find_program(LLVM_RANLIB_EXECUTABLE NAMES patmos-ranlib patmos-llvm-ranlib llvm-ranlib DOC "Path to the llvm-ranlib tool.")

if(NOT LLVM_RANLIB_EXECUTABLE)
  message(FATAL_ERROR "llvm-ranlib required for a Patmos build.")
endif()

set(CMAKE_RANLIB ${LLVM_RANLIB_EXECUTABLE} CACHE FILEPATH "Ranlib tool")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-link
find_program(LLVM_LINK_EXECUTABLE NAMES patmos-llvm-link llvm-link DOC "Path to the llvm-link tool.")

if(NOT LLVM_LINK_EXECUTABLE)
  message(FATAL_ERROR "llvm-link required for a Patmos build.")
endif()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-dis
find_program(LLVM_DIS_EXECUTABLE NAMES patmos-llvm-dis llvm-dis DOC "Path to the llvm-dis tool.")

if(NOT LLVM_DIS_EXECUTABLE)
  message(FATAL_ERROR "llvm-dis required for a Patmos build.")
endif()

set(CMAKE_DIS ${LLVM_DIS_EXECUTABLE} CACHE FILEPATH "LLVM disassembler")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-nm
find_program(LLVM_NM_EXECUTABLE NAMES patmos-llvm-nm llvm-nm DOC "Path to the llvm-nm tool.")

if(NOT LLVM_NM_EXECUTABLE)
  message(FATAL_ERROR "llvm-nm required for a Patmos build.")
endif()

set(CMAKE_NM ${LLVM_NM_EXECUTABLE} CACHE FILEPATH "Archive inspector")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find simulator & emulator

find_program(PASIM_EXECUTABLE NAMES pasim DOC "Path to the Patmos simulator pasim.")
set(PASIM_OPTIONS "-M fifo -m 16k" CACHE STRING "Additional command-line options passed to the Patmos simulator.")
separate_arguments(PASIM_OPTIONS)

find_program(PATMOS_EMULATOR NAMES patmos-emulator DOC "Path to the Chisel-based patmos emulator.")
set(PATMOS_EMULATOR_OPTIONS "" CACHE STRING "Additional command-line options passed to the Chisel-based patmos emulator.")
separate_arguments(PATMOS_EMULATOR_OPTIONS)

function (run_sim sim sim_options name prog in out ref)
  # Create symlinks to programs to make job_patmos.sh happy
  string(REGEX REPLACE "^[a-zA-Z0-9]+-" "" _progname ${name})
  file(TO_CMAKE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${_progname} _namepath)
  file(TO_CMAKE_PATH ${prog} _progpath)
  if (NOT ${_namepath} STREQUAL ${_progpath})
    add_custom_command(OUTPUT ${_namepath} COMMAND ${CMAKE_COMMAND} -E remove -f ${_namepath} COMMAND ${CMAKE_COMMAND} -E create_symlink ${prog} ${_namepath})
    add_custom_target(${name} ALL SOURCES ${_namepath})
  endif()
  set(SIM_ARGS ${sim_options})
  if(NOT ${in} STREQUAL "")
    list(APPEND SIM_ARGS -I ${in})
  endif()
  if(NOT ${out} STREQUAL "")
    list(APPEND SIM_ARGS -O ${out})
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${out})
  endif()
  add_test(NAME ${name} COMMAND ${sim} ${SIM_ARGS} ${prog})
  if(NOT ${ref} STREQUAL "")
    add_test(NAME ${name}-cmp COMMAND ${CMAKE_COMMAND} -E compare_files ${out} ${ref})
    set_tests_properties(${name}-cmp PROPERTIES DEPENDS ${name})
  endif()
endfunction (run_sim)

macro (run_io name prog in out ref)
  if(PASIM_EXECUTABLE)
    set(ENABLE_TESTING true)
    set(SIM_ARGS ${PASIM_OPTIONS} -o ${name}.stats)
    run_sim(${PASIM_EXECUTABLE} "${SIM_ARGS}" "${name}" "${prog}" "${in}" "${out}" "${ref}")
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${name}.stats)
  else()
    if(REQUIRES_PASIM)
      message(FATAL_ERROR "pasim required for a Patmos build.")
    else()
      message(WARNING "pasim not found, testing is disabled.")
    endif()
  endif()
  if(${name}-run-hw-test)
    set(ENABLE_TESTING true)
    set(EMU_ARGS ${PATMOS_EMULATOR_OPTIONS} -q)
    separate_arguments(EMU_ARGS)
    run_sim(${PATMOS_EMULATOR} "${EMU_ARGS}" "${name}_hw" ${prog} "${in}" "${out}" "${ref}")
    set_tests_properties(${name}_hw PROPERTIES TIMEOUT 120)
  endif()
endmacro(run_io)


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find platin

find_program(PLATIN NAMES platin DOC "Path to platin tool.")

set(PLATIN_OPTIONS "" CACHE STRING "Additional command-line options passed to the platin tool.")

if(PLATIN)
  macro (run_wcet name prog report timeout factor entry)
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${report} ${report}.dir)
    add_test(NAME ${name} COMMAND ${PLATIN} wcet --recorders "g:cil/0,f/0:b/0" --analysis-entry ${entry} --use-trace-facts  --binary ${prog} --outdir tmp --report ${report} --input ${prog}.pml)
    # add  --check ${factor} as soon as aiT is ready for the new patmos ISA
    set_tests_properties(${name} PROPERTIES TIMEOUT ${timeout})
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${report})
  endmacro(run_wcet)
else()
  message(WARNING "platin not found - WCET analysis disabled")
endif()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
