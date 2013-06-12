INCLUDE(CMakeForceCompiler)

# this one is important
SET(CMAKE_SYSTEM_NAME mpc55xx)
SET(CMAKE_SYSTEM_PROCESSOR mpc5554)

SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find CodeSourcery tools
find_program(POWERPC_GCC_EXECUTABLE NAMES powerpc-eabi-gcc DOC "Path to GCC for PowerPC.")

if(NOT POWERPC_GCC_EXECUTABLE)
  message(FATAL_ERROR "powerpc-eabi-gcc not found.")
endif()

get_filename_component(POWERPC_BASE ${POWERPC_GCC_EXECUTABLE} PATH)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find clang for cross compiling
find_program(CLANG_EXECUTABLE NAMES clang DOC "Path to the clang front-end.")

if(NOT CLANG_EXECUTABLE)
  message(FATAL_ERROR "clang required for a mpc5554 build.")
endif()

CMAKE_FORCE_C_COMPILER(${CLANG_EXECUTABLE} GNU)
CMAKE_FORCE_CXX_COMPILER(${CLANG_EXECUTABLE} GNU)

# set some compiler-related variables;
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> -ccc-host-triple powerpc-unknown-linux -emit-llvm -Xclang -isystem${POWERPC_BASE}/../powerpc-eabi/include -D__IEEE_LITTLE_ENDIAN <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>")
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> -ccc-host-triple powerpc-unknown-linux <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> -ccc-host-triple powerpc-unknown-linux -emit-llvm -Xclang -isystem${POWERPC_BASE}/../powerpc-eabi/include -D__IEEE_LITTLE_ENDIAN <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>")
set(CMAKE_FORCE_C_OUTPUT_EXTENSION ".bc" FORCE)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-config
find_program(LLVM_CONFIG_EXECUTABLE NAMES llvm-config DOC "Path to the llvm-config tool.")

if(NOT LLVM_CONFIG_EXECUTABLE)
  message(FATAL_ERROR "LLVM required for a mpc5554 build.")
endif()

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --targets-built
                OUTPUT_VARIABLE LLVM_TARGETS
                OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT (${LLVM_TARGETS} MATCHES "PowerPC"))
  message(FATAL_ERROR "LLVM target 'powerpc' required for a mpc5554 build.")
endif()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ar
find_program(LLVM_AR_EXECUTABLE NAMES llvm-ar DOC "Path to the llvm-ar tool.")

if(NOT LLVM_AR_EXECUTABLE)
  message(FATAL_ERROR "llvm-ar required for a mpc5554 build.")
endif()

set(CMAKE_FORCE_AR ${LLVM_AR_EXECUTABLE})

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ranlib
find_program(LLVM_RANLIB_EXECUTABLE NAMES llvm-ranlib DOC "Path to the llvm-ranlib tool.")

if(NOT LLVM_RANLIB_EXECUTABLE)
  message(FATAL_ERROR "llvm-ranlib required for a mpc5554 build.")
endif()

set(CMAKE_FORCE_RANLIB ${LLVM_RANLIB_EXECUTABLE})

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ld
find_program(LLVM_LD_EXECUTABLE NAMES llvm-ld DOC "Path to the llvm-ld tool.")

if(NOT LLVM_LD_EXECUTABLE)
  message(FATAL_ERROR "llvm-ld required for a mpc5554 build.")
endif()

# #   set(CMAKE_C_LINK_EXECUTABLE   "${LLVM_LD_EXECUTABLE}  -v -disable-internalize -Xlinker=-nostdlib -Xlinker=-te500v1 -Xlinker=-T${CMAKE_SOURCE_DIR}/Debie1-e/code/mpc5554/gcc/linker-mpc55xx-gcc.ld -native -native-gcc=${POWERPC_GCC_EXECUTABLE} <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")
# -native-keep 
set(CMAKE_C_LINK_EXECUTABLE   "${LLVM_LD_EXECUTABLE} -disable-opt -lowerswitch -disable-internalize -Xllc=-O3 -Xlinker=-te500v1 -Xlinker=-Tsim.ld -Xlinker=-Wl,--defsym,__cs3_reset_sim=0x0 -native -native-gcc=${POWERPC_GCC_EXECUTABLE} <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find simulator

find_program(PPCRUN_EXECUTABLE NAMES powerpc-eabi-run DOC "Path to the Patmos simulator pasim.")

if(PPCRUN_EXECUTABLE)
  set(ENABLE_TESTING true)
  macro (run_io name prog in out ref)
    # Note: redirections do not work this way; this seems to be untested
    add_test(NAME ${name} COMMAND ${PPCRUN_EXECUTABLE} -i ${prog} < ${in} > ${out})
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${out})

    if(NOT ${ref} STREQUAL "")
      add_test(NAME ${name}-cmp COMMAND ${CMAKE_COMMAND} -E compare_files ${out} ${ref})
      set_tests_properties(${name}-cmp PROPERTIES DEPENDS ${name})
    endif()
  endmacro (run_io)
else()
  message(FATAL_ERROR "powerpc-eabi-run required for a mpc5554 build.")
endif()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
