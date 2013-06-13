INCLUDE(CMakeForceCompiler)

# this one is important
SET(CMAKE_SYSTEM_NAME leon3)
SET(CMAKE_SYSTEM_PROCESSOR leon3)

SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find CodeSourcery tools
find_program(SPARC_GCC_EXECUTABLE NAMES sparc-leon3-none-gcc sparc-elf-gcc DOC "Path to GCC for Leon.")

if(NOT SPARC_GCC_EXECUTABLE)
  message(FATAL_ERROR "sparc-leon3-none-gcc or sparc-elf-gcc required for a leon3 build.")
endif()

get_filename_component(SPARC_BASE ${SPARC_GCC_EXECUTABLE} PATH)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find clang for cross compiling
find_program(CLANG_EXECUTABLE NAMES clang DOC "Path to the clang front-end.")

if(NOT CLANG_EXECUTABLE)
  message(FATAL_ERROR "clang required for a leon3 build.")
endif()

CMAKE_FORCE_C_COMPILER(${CLANG_EXECUTABLE} GNU)
CMAKE_FORCE_CXX_COMPILER(${CLANG_EXECUTABLE} GNU)

# set some compiler-related variables;
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> -ccc-host-triple sparc-unknown-linux -emit-llvm -Xclang -isystem${SPARC_BASE}/../sparc-leon3-none/include/ <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>")
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> -ccc-host-triple sparc-unknown-linux <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> -ccc-host-triple sparc-unknown-linux -emit-llvm -Xclang -isystem${SPARC_BASE}/../sparc-leon3-none/include/ <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>")
set(CMAKE_FORCE_C_OUTPUT_EXTENSION ".bc" FORCE)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-config
find_program(LLVM_CONFIG_EXECUTABLE NAMES llvm-config DOC "Path to the llvm-config tool.")

if(NOT LLVM_CONFIG_EXECUTABLE)
  message(FATAL_ERROR "LLVM required for a leon3 build.")
endif()

execute_process(COMMAND ${LLVM_CONFIG_EXECUTABLE} --targets-built
                OUTPUT_VARIABLE LLVM_TARGETS
                OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT (${LLVM_TARGETS} MATCHES "Sparc"))
  message(FATAL_ERROR "LLVM target 'sparc' required for a leon3 build.")
endif()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ar
find_program(LLVM_AR_EXECUTABLE NAMES llvm-ar DOC "Path to the llvm-ar tool.")

if(NOT LLVM_AR_EXECUTABLE)
  message(FATAL_ERROR "llvm-ar required for a leon3 build.")
endif()

set(CMAKE_FORCE_AR ${LLVM_AR_EXECUTABLE})

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ranlib
find_program(LLVM_RANLIB_EXECUTABLE NAMES llvm-ranlib DOC "Path to the llvm-ranlib tool.")

if(NOT LLVM_RANLIB_EXECUTABLE)
  message(FATAL_ERROR "llvm-ranlib required for a leon3 build.")
endif()

set(CMAKE_FORCE_RANLIB ${LLVM_RANLIB_EXECUTABLE})

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find llvm-ld
find_program(LLVM_LD_EXECUTABLE NAMES llvm-ld DOC "Path to the llvm-ld tool.")

if(NOT LLVM_LD_EXECUTABLE)
  message(FATAL_ERROR "llvm-ld required for a leon3 build.")
endif()

set(CMAKE_C_LINK_EXECUTABLE   "${LLVM_LD_EXECUTABLE} -disable-opt -disable-internalize -native -native-keep -native-gcc=${SPARC_GCC_EXECUTABLE} <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

