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


# RTEMS linking support
if(${TRIPLE} MATCHES "patmos-unknown-rtems")
  message("=====")
  message("RTEMS based build... (EXPERIMENTAL)")
  message("=====")

  # XXX should this be set?
  SET(CMAKE_SYSTEM_NAME rtems)

  if(NOT (IS_DIRECTORY ${RTEMS_LIBPATH}))
    message(FATAL_ERROR "path to RTEMS libs missing")
  endif()

  # custom link command
  set(CMAKE_C_LINK_EXECUTABLE  "<CMAKE_C_COMPILER> -target ${TRIPLE} -fno-builtin <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> -mpreemit-bitcode=<TARGET>.bc -mserialize=<TARGET>.pml ${RTEMS_LIBPATH}/start.o ${RTEMS_LIBPATH}/libsyms.ll -l=c <LINK_LIBRARIES> -nostartfiles -Xgold -Map -Xgold map.map -Xgold --script=${RTEMS_LIBPATH}/linkcmds -Xopt -disable-internalize")

  # this does not work for the RTEMS libraries
  #set(CMAKE_FIND_LIBRARY_PREFIXES "")
  #set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
  #find_library(rtemscpu NAMES "rtemscpu" PATHS RTEMS_LIBPATH)
endif()

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
# find llvm-objdump
find_program(LLVM_OBJDUMP_EXECUTABLE NAMES patmos-llvm-objdump llvm-objdump DOC "Path to the llvm-objdump tool.")

if(NOT LLVM_OBJDUMP_EXECUTABLE)
  message(FATAL_ERROR "llvm-objdump required for a Patmos build.")
endif()

set(CMAKE_OBJDUMP ${LLVM_OBJDUMP_EXECUTABLE} CACHE FILEPATH "Object dumper")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find simulator & emulator

find_program(PASIM_EXECUTABLE NAMES pasim DOC "Path to the Patmos simulator pasim.")
set(PASIM_OPTIONS "-M fifo -m 2k" CACHE STRING "Additional command-line options passed to the Patmos simulator.")
separate_arguments(PASIM_OPTIONS)

find_program(PATMOS_EMULATOR NAMES patmos-emulator DOC "Path to the Chisel-based patmos emulator.")
set(PATMOS_EMULATOR_OPTIONS "" CACHE STRING "Additional command-line options passed to the Chisel-based patmos emulator.")
separate_arguments(PATMOS_EMULATOR_OPTIONS)

if(PASIM_EXECUTABLE)
  set(ENABLE_TESTING true)
else()
  if(REQUIRES_PASIM)
    message(FATAL_ERROR "pasim required for a Patmos build.")
  else()
    message(WARNING "pasim not found, testing is disabled.")
  endif()
endif()
if(PATMOS_EMULATOR)
  set(ENABLE_TESTING true)
else()
  message(WARNING "patmos-emulator not found, testing with emulator is disabled.")
endif()

function (run_sim sim sim_options name prog in out ref)
  # Create symlinks to programs to make job_patmos.sh happy
  string(REGEX REPLACE "^[a-zA-Z0-9]+-(.*)" "\\1" _progname ${name})
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
    set(SIM_ARGS ${PASIM_OPTIONS} -o ${name}.stats)
    run_sim(${PASIM_EXECUTABLE} "${SIM_ARGS}" "${name}" "${prog}" "${in}" "${out}" "${ref}")
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${name}.stats)
  endif()
  if(${name}-run-hw-test AND PATMOS_EMULATOR)
    set(EMU_ARGS ${PATMOS_EMULATOR_OPTIONS} -q)
    separate_arguments(EMU_ARGS)
    run_sim(${PATMOS_EMULATOR} "${EMU_ARGS}" "${name}_hw" ${prog} "${in}" "${out}" "${ref}")
    set_tests_properties(${name}_hw PROPERTIES TIMEOUT 120)
  endif()
endmacro(run_io)


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find platin

set(PLATIN_ENABLE_WCET true CACHE BOOL "Enable WCET analysis during tests using Platin.")
set(PLATIN_ENABLE_AIT true CACHE BOOL "Enable aiT-based WCET analysis during tests using Platin.")

find_program(PLATIN_EXECUTABLE NAMES platin DOC "Path to platin tool.")

set(PLATIN_OPTIONS "" CACHE STRING "Additional command-line options passed to the platin tool.")

if (PLATIN_ENABLE_WCET)
  if (NOT PLATIN_EXECUTABLE)
    message(WARNING "platin not found, WCET analysis is disabled.")
  endif()
else()
  message("WCET analysis with platin manually disabled, will be skipped.")
endif()

if (A3_EXECUTABLE AND PLATIN_ENABLE_AIT)
  set(PLATIN_WCA_TOOL --a3-command ${A3_EXECUTABLE})
else()
  set(PLATIN_WCA_TOOL --disable-ait --enable-wca)
endif()

macro (run_wcet name prog report timeout factor entry)
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${report} ${report}.dir)
  add_test(NAME ${name} COMMAND ${PLATIN_EXECUTABLE} wcet --recorders "g:bcil" --analysis-entry ${entry}
                                                          --use-trace-facts  --binary ${prog} --report ${report} --input ${PLATIN_CONFIG}
                                                          --input ${prog}.pml --check ${factor}
                                                          --objdump-command ${LLVM_OBJDUMP_EXECUTABLE} --pasim-command ${PASIM_EXECUTABLE}
                                                          ${PLATIN_WCA_TOOL} ${PLATIN_OPTIONS})
  set_tests_properties(${name} PROPERTIES TIMEOUT ${timeout})
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${report})
endmacro(run_wcet)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# stack cache analysis (and pml export) test

set(ENABLE_STACK_CACHE_ANALYSIS_TESTING true CACHE BOOL "Enable tests for LLVM-based SC analysis")

find_program(ILP_SOLVER NAMES glpsol DOC "Path to GLPK solver.")

if (ENABLE_STACK_CACHE_ANALYSIS_TESTING)
  if (NOT ILP_SOLVER)
    message(WARNING "no ILP solver found, SCA analysis tests disabled.")
  endif()
  if (NOT PLATIN_EXECUTABLE)
    message(WARNING "platin not found, SCA analysis tests disabled.")
  endif()
else()
  message("LLVM-based SC analysis tests will be skipped.")
endif()

# bounds file can be empty ("")
macro (set_sca_options target bounds_file)
  if (ENABLE_STACK_CACHE_ANALYSIS_TESTING AND ILP_SOLVER AND "${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
    # enables SCA analysis when building target
    get_target_property(existing_link_flags ${target} LINK_FLAGS)
    if(${existing_link_flags})
      message(FATAL_ERROR "set_sca_options about to reset linker flags")
    endif()
    set(props "-mpatmos-enable-stack-cache-analysis -mpatmos-ilp-solver=${PROJECT_SOURCE_DIR}/scripts/solve_ilp_glpk.sh -mpatmos-stack-cache-size=256")
    if (NOT "${bounds_file}" STREQUAL "")
      set(props "${props} -mpatmos-stack-cache-analysis-bounds=${bounds_file}")
    endif()
    set_target_properties(${target} PROPERTIES LINK_FLAGS "${props}")
  endif()
endmacro(set_sca_options)

macro (make_ais name prog pml)
  if (ENABLE_STACK_CACHE_ANALYSIS_TESTING AND ILP_SOLVER AND PLATIN_EXECUTABLE AND "${CMAKE_SYSTEM_NAME}" MATCHES "patmos")

    add_test(NAME ${name}-sym COMMAND ${PLATIN_EXECUTABLE} extract-symbols -i ${pml} -o ${prog}.addr.pml ${prog})
    add_test(NAME ${name}-ais COMMAND ${PLATIN_EXECUTABLE} pml2ais --ais ${prog}.ais ${prog}.addr.pml)

    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${prog}.addr.pml ${prog}.ais)
  endif()
endmacro(make_ais)
