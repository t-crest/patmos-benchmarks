file(GLOB SOURCES "${GCC_C_TORTURE_EXECUTE_PATH}/*.c")

# Sources that fail on host
# TODO: Update when changing compiler version
file(STRINGS FailHost.txt SOURCES_FAIL_HOST)

# Sources that fail building for Patmos
# TODO: Try to get rid of the build errors
file(STRINGS FailBuildTarget.txt SOURCES_FAIL_BUILDTARGET)

# Sources that cannot be run on HW due to SPM size constraints
file(STRINGS NoHwTest.txt SOURCES_NO_HW_TEST)

# executable for each .c file
foreach(SRC ${SOURCES})

  get_filename_component(EXEC_NAME ${SRC} NAME_WE)

  list(FIND SOURCES_FAIL_HOST ${EXEC_NAME} FAIL_BUILD)
  list(FIND SOURCES_FAIL_BUILDTARGET ${EXEC_NAME} FAIL_BUILDTARGET)
  list(FIND SOURCES_NO_HW_TEST ${EXEC_NAME} NO_HW_TEST)

  if((${FAIL_BUILD} EQUAL -1) AND (${FAIL_BUILDTARGET} EQUAL -1))

    add_executable(${EXEC_NAME} ${SRC})
    if(${NO_HW_TEST} EQUAL -1)
        set(torture-${EXEC_NAME}-run-hw-test true)
    endif()

    run_io(torture-${EXEC_NAME}
      "${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}" "" "" "")

    # A little bit of optimization and calm down warnings
    set(COMPILE_FLAGS "-O1 -Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-type -fbuiltin")
    set(LINK_FLAGS "")

    # On Patmos, compile for SPM if HW test is enabled
    if("${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
      set(TARGET_COMPILE_FLAGS "-DSTACK_SIZE=1024 -DNO_TRAMPOLINES")
      if (${NO_HW_TEST} EQUAL -1)
          set(TARGET_LINK_FLAGS "-Xgold -T${PROJECT_SOURCE_DIR}/scripts/patmos-spm.t -mpatmos-method-cache-size=0x4000 -mpatmos-stack-base=0x3000 -mpatmos-shadow-stack-base=0x4000")
      else()
          set(TARGET_LINK_FLAGS "-mpatmos-method-cache-size=0x4000")
      endif()
	endif()

	set_target_properties(${EXEC_NAME} PROPERTIES COMPILE_FLAGS
	  "${COMPILE_FLAGS} ${TARGET_COMPILE_FLAGS}")
	set_target_properties(${EXEC_NAME} PROPERTIES LINK_FLAGS
	  "${LINK_FLAGS} ${TARGET_LINK_FLAGS}")

  endif()

endforeach(SRC)
