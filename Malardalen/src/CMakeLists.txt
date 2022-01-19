set( SOURCES
  bs.c
  adpcm.c
  bsort100.c
  cnt.c
  compress.c
  cover.c
  crc.c
  duff.c # non-natural loops with -O0
  edn.c
  expint.c
  fac.c # recursiv
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
  nsichneu.c
  qsort-exam.c
  qurt.c
  recursion.c # recursive
  select.c
  sqrt.c
  statemate.c
  st.c
  ud.c
  whet.c
  )
set( SOURCES_NO_HW ) # exceed memory size
set( SOURCES_NO_WCET fac.c recursion.c duff.c) # recursion, non-natural loops

# executable for each .c file
foreach( SRC ${SOURCES} )
  get_filename_component(EXEC_NAME ${SRC}  NAME_WE )

  add_executable( ${EXEC_NAME} ${SRC} )

  list(FIND SOURCES_NO_HW ${SRC} DISABLE_HW)
  if(${DISABLE_HW} EQUAL -1)
    setup_build_for_emulator(${EXEC_NAME})
    enable_emulator_test(mrtc-${EXEC_NAME})
  endif()

  run_io(mrtc-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME} "" "" "")

  # Platin WCET analysis
  list(FIND SOURCES_NO_WCET ${SRC} DISABLE_WCA)
  if(${DISABLE_WCA} EQUAL -1)
    run_wcet(mrtc_platin-${EXEC_NAME}
             ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}
             ${CMAKE_CURRENT_BINARY_DIR}/mrtc-${EXEC_NAME}-wcet.txt
             360
             4
             main)
  endif()
endforeach(SRC)

