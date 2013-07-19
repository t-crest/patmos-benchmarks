file(GLOB SOURCES "${GCC_C_TORTURE_EXECUTE_PATH}/*.c")

# Sources that fail building for x86 and Patmos
# TODO: Update when changing compiler version
set(SOURCES_FAIL_BUILD
  20010209-1
  20010605-1
  20010724-1
  20020412-1
  20030501-1
  20040308-1
  20040423-1
  20040520-1
  20041218-2
  20050107-1
  20050119-1
  20050119-2
  20061220-1
  20070919-1
  20071018-1
  20071120-1
  20090219-1
  920302-1
  920415-1
  920501-3
  920612-2
  920721-4
  920728-1
  921017-1
  980608-1
  980709-1
  align-nest
  bcp-1
  nest-align-1
  nestfunc-7
  nest-stdar-1
  pr22061-3
  pr22061-4
  pr23135
  pr36765
  pr39228
  pr41935
  pr42833
  pr43008
  pr47237
  simd-1
  va-arg-pack-1
  vector-shift1
  va-arg-7
  va-arg-8
  vector-subscript-1)

# Sources that fail building for Patmos
# TODO: Try to get rid of the build errors
set(SOURCES_FAIL_BUILDTARGET
  20010122-1
  20020314-1
  20021113-1
  20030125-1
  20040223-1
  20040811-1
  920625-1
  920908-1
  931004-10
  931004-12
  931004-14
  931004-2
  931004-4
  931004-6
  931004-8
  941202-1
  980526-1
  990208-1
  990413-2
  built-in-setjmp
  builtin-bitops-1
  frame-address
  loop-2f
  loop-2g
  pr17377
  pr22061-1
  pr22098-1
  pr22098-2
  pr22098-3
  pr38151
  pr40022
  pr40657
  pr43220
  pr44575
  pr51447
  pr53645
  pr53645-2
  pr56866
  scal-to-vec1
  scal-to-vec2
  scal-to-vec3
  stdarg-3
  simd-6
  strct-stdarg-1
  strct-varg-1
  va-arg-22
  vector-shift
  vla-dealloc-1)


# executable for each .c file
foreach(SRC ${SOURCES})

  get_filename_component(EXEC_NAME ${SRC} NAME_WE)

  list(FIND SOURCES_FAIL_BUILD ${EXEC_NAME} FAIL_BUILD)  
  list(FIND SOURCES_FAIL_BUILDTARGET ${EXEC_NAME} FAIL_BUILDTARGET)

  if((${FAIL_BUILD} EQUAL -1) AND (${FAIL_BUILDTARGET} EQUAL -1))
	add_executable(${EXEC_NAME} ${SRC})
	set(torture-${EXEC_NAME}-run-hw-test true)

	run_io(torture-${EXEC_NAME}
	  "${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}" "" "" "")

	# A little bit of optimization and calm down warnings
	set(COMPILE_FLAGS "-O1 -Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-type")
	# Link against libm
	set(LINK_FLAGS "-lm")

	if("${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
      # On Patmos, compile for SPM
      set(TARGET_COMPILE_FLAGS "-DSTACK_SIZE=1024 -DNO_TRAMPOLINES")
      set(TARGET_LINK_FLAGS "-Xgold -T${PROJECT_SOURCE_DIR}/scripts/patmos-spm.t -mpatmos-method-cache-size=0x8000 -mpatmos-stack-base=0x3000 -mpatmos-shadow-stack-base=0x4000")
	endif()

	set_target_properties(${EXEC_NAME} PROPERTIES COMPILE_FLAGS 
	  "${COMPILE_FLAGS} ${TARGET_COMPILE_FLAGS}")
	set_target_properties(${EXEC_NAME} PROPERTIES LINK_FLAGS 
	  "${LINK_FLAGS} ${TARGET_LINK_FLAGS}")

  endif()

endforeach(SRC)
