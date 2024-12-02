file(GLOB SOURCES "${GCC_C_TORTURE_EXECUTE_PATH}/*.c" "${GCC_C_TORTURE_EXECUTE_PATH}/ieee/*.c")

# Sources that fail on host
# TODO: Update when changing compiler version
file(STRINGS FailHost.txt SOURCES_FAIL_HOST)

# Sources that fail building for Patmos
# TODO: Try to get rid of the build errors
SET(SOURCES_FAIL_BUILDTARGET 
	"20040811-1"
	"920625-1"
	"920908-1"
	"931004-10"
	"931004-12"
	"931004-14"
	"931004-2"
	"931004-4"
	"931004-6"
	"931004-8"
	"980526-1"
	"990413-2"
	"built-in-setjmp"
	"frame-address"
	"loop-2f"
	"loop-2g"
	"pr17377"
	"pr38151"
	"pr40022"
	"pr40657"
	"pr43220"
	"pr44575"
	"pr53645"
	"pr53645-2"
	"pr56866"
	"pr60003"
	"pr60960"
	"pr65053-2"
	"simd-6"
	"stdarg-3"
	"strct-stdarg-1"
	"strct-varg-1"
	"va-arg-22"
	"vla-dealloc-1"
	"20030323-1"
	"complex-5" # Uses '__divsc3'
	# Following fail on new LLVM at runtime but only on pasim (succeed on patemu)
	"20031003-1"
    "20040409-1"
    "20040409-2"
    "20040409-3"
    "20040709-1"
    "20040709-2"
    "920711-1"
	"930518-1"
    "930529-1" # Infinite loop
    "950809-1"
    "960312-1" 
    "pr23047"
	"20021127-1"
)

# Sources that fail during a non-optimizing (-O0) build
file(STRINGS FailO0.txt SOURCES_FAIL_NONOPT)

# Sources that cannot be run on HW due to size constraints
file(STRINGS NoHwTest.txt SOURCES_NO_HW_TEST)

# executable for each .c file
foreach(SRC ${SOURCES})

  get_filename_component(SRCPATH ${SRC} PATH)
  get_filename_component(SRCNAME ${SRC} NAME_WE)

  if (${SRCPATH} STREQUAL ${GCC_C_TORTURE_EXECUTE_PATH})
    set(EXEC_NAME "${SRCNAME}")
  else()
    get_filename_component(SRCDIR ${SRCPATH} NAME_WE)
    set(EXEC_NAME "${SRCDIR}_${SRCNAME}")
  endif()

  list(FIND SOURCES_FAIL_HOST ${EXEC_NAME} FAIL_BUILD)
  list(FIND SOURCES_FAIL_BUILDTARGET ${EXEC_NAME} FAIL_BUILDTARGET)
  list(FIND SOURCES_NO_HW_TEST ${EXEC_NAME} NO_HW_TEST)

  if (CMAKE_BUILD_TYPE MATCHES Debug|O0)
    list(FIND SOURCES_FAIL_NONOPT ${EXEC_NAME} FAIL_NONOPT)
  else()
    set(FAIL_NONOPT -1)
  endif()

  if((${FAIL_BUILD} EQUAL -1) AND (${FAIL_BUILDTARGET} EQUAL -1) AND (${FAIL_NONOPT} EQUAL -1))

    add_executable(${EXEC_NAME} ${SRC})
    if(${NO_HW_TEST} EQUAL -1)
	setup_build_for_emulator(${EXEC_NAME})
	enable_emulator_test(torture-${EXEC_NAME})
    endif()

    run_io(torture-${EXEC_NAME}
      "${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}" "" "" "")

    # Calm down warnings
    set(COMPILE_FLAGS "-Wno-conversion -Wno-implicit-int -Wno-return-type -fbuiltin")

    # On Patmos, compile for RAM if HW test is enabled
    if("${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
      set(TARGET_COMPILE_FLAGS "-DSTACK_SIZE=1024 -DNO_TRAMPOLINES")
      # XXX Why this?
      #set(TARGET_LINK_FLAGS "-mpatmos-method-cache-size=0x800")
    endif()

    set_target_properties(${EXEC_NAME} PROPERTIES COMPILE_FLAGS
      "${COMPILE_FLAGS} ${TARGET_COMPILE_FLAGS}")

    TARGET_LINK_LIBRARIES(${EXEC_NAME} "m")

  endif()

endforeach(SRC)

if (CMAKE_BUILD_TYPE MATCHES Debug|O0)
  message("gcc.c-torture: assuming -O0 build, some tests will not be built")
endif()
