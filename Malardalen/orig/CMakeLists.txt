

set( SOURCES
  adpcm.c
  bs.c
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
  ns.c
  nsichneu.c
  qsort-exam.c
  qurt.c
  select.c
  sqrt.c
  statemate.c
  )

# executable for each .c file
foreach( SRC ${SOURCES} )
  get_filename_component(EXEC_NAME ${SRC}  NAME_WE )
  add_executable( ${EXEC_NAME} ${SRC} )
  set_target_properties( ${EXEC_NAME} PROPERTIES
                         COMPILE_FLAGS "-O0 -fno-builtin")
  #set_target_properties( ${EXEC_NAME} PROPERTIES
  #                       LINK_FLAGS "-Wl,--disable-opt") # no LTO

#  run_io(mrtc-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}
#         ${CURRENT_SOURCE_DIR}/../inputs/${EXEC_NAME}.in
#         ${EXEC_NAME}.out
#         ${CURRENT_SOURCE_DIR}/../outputs/${EXEC_NAME}.ref
#         )
endforeach(SRC)

