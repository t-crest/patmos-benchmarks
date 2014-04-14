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

foreach( SRC ${SOURCES} )
  get_filename_component(EXEC_NAME ${SRC}  NAME_WE )

  add_executable( ${EXEC_NAME} ${SRC} )

  run_io(mrtc-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME} "" "" "")
endforeach(SRC)
