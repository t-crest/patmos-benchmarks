set( SOURCES
  adpcm_decoder.c
  adpcm_encoder.c
  binarysearch.c
  bsort100.c
  compress.c
  countnegative.c
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
  lms.c
  ludcmp.c
  matmult.c
  minver.c
  ndes.c
  petrinet.c
  prime.c
  qsort-exam.c
  qurt.c
  recursion.c
  select.c
  sqrt.c
  statemate.c
  st.c
  )

set( SOURCES_NO_HW ) # exceed memory size
set( SOURCES_NO_WCET fac.c recursion.c duff.c compress.c) # recursion, non-natural loops

# executable for each .c file
foreach( SRC ${SOURCES} )
  get_filename_component(EXEC_NAME ${SRC}  NAME_WE )

  add_executable( ${EXEC_NAME} ${SRC} )

  list(FIND SOURCES_NO_HW ${SRC} DISABLE_HW)
  if(${DISABLE_HW} EQUAL -1)
    setup_build_for_emulator(${EXEC_NAME})
    enable_emulator_test(mrtc-${EXEC_NAME})
  endif()

  use_source_flowfacts(mrtc_platin-${EXEC_NAME})
  # add_pml_input(mrtc_platin-${EXEC_NAME} flow.pml)

  run_io(mrtc-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME} "" "" "")

  # Platin WCET analysis
  list(FIND SOURCES_NO_WCET ${SRC} DISABLE_WCA)
  if(${DISABLE_WCA} EQUAL -1)
    run_wcet(mrtc_platin-${EXEC_NAME}
             ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}
             ${CMAKE_CURRENT_BINARY_DIR}/mrtc-${EXEC_NAME}-wcet.txt
             360
             16 # needs high factor because we do not use trace facts
             main)
  endif()
endforeach(SRC)

