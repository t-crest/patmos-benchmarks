set( SOURCES
  bs.c
  adpcm.c
  bsort100.c
  cnt.c
  compress.c
  cover.c
  crc.c
  duff.c
  edn.c
  expint.c
  fac.c
  fdct.c
  fft1.c
  fibcall.c
  fir.c
  insertsort.c
  janne_complex.c
  jfdctint.c
  lcdnum.c
  lms.c # renamed sqrt to mysqrt
  loop3.c
  ludcmp.c
  matmult.c
  minmax.c
  minver.c
  ndes.c
  ns.c
  nsichneu.c # exceed method cache size?
  qsort-exam.c
  qurt.c
  recursion.c
  select.c
  sqrt.c
  statemate.c
  # st.c # needs math library
  ud.c
  # whet.c # needs math library
  )
set( SOURCES_NO_HW adpcm.c ludcmp.c nsichneu.c )
set( PASIM_OPTIONS "")

# executable for each .c file
foreach( SRC ${SOURCES} )
  get_filename_component(EXEC_NAME ${SRC}  NAME_WE )

  add_executable( ${EXEC_NAME} ${SRC} )

  list(FIND SOURCES_NO_HW ${SRC} ENABLE_HW)
  if(${ENABLE_HW} EQUAL -1)
    set(mrtc-${EXEC_NAME}-run-hw-test true)
  endif()

  run_io(mrtc-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME} "" "" "")

  if("${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
    # On Patmos, compile for SPM, and run emulator tests
    set_target_properties( ${EXEC_NAME} PROPERTIES
                            COMPILE_FLAGS "-DSTACK_SIZE=1024")
    set_target_properties( ${EXEC_NAME} PROPERTIES
                            LINK_FLAGS "-Xgold -T${PROJECT_SOURCE_DIR}/scripts/patmos-spm.t -mpatmos-method-cache-size=0x800 -mpatmos-stack-base=0x3000 -mpatmos-shadow-stack-base=0x4000" )
    run_wcet(mrtc_platin-${EXEC_NAME}
             ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}
             ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}-wcet.txt
             360 1.2
             main)
  endif()
endforeach(SRC)

