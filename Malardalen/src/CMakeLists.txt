

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
  # nsichneu.c # exceed method cache size?
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

  if("${CMAKE_SYSTEM_NAME}" MATCHES "patmos")
    # On Patmos, compile for SPM, and run emulator tests
    set_target_properties( ${EXEC_NAME} PROPERTIES
                            COMPILE_FLAGS "-O0 -fno-builtin -DSTACK_SIZE=1024")
    set_target_properties( ${EXEC_NAME} PROPERTIES
                            LINK_FLAGS "-Xgold -T${PROJECT_SOURCE_DIR}/scripts/patmos-spm.t -mpatmos-method-cache-size=0x8000 -mpatmos-stack-base=0x3000 -mpatmos-shadow-stack-base=0x4000" )
    run_emulator(mrtc_emulator-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME} /dev/null ${EXEC_NAME}.out "" 10)
  endif()

  run_io(mrtc-${EXEC_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${EXEC_NAME}
         ${CMAKE_CURRENT_SOURCE_DIR}/../outputs/empty.txt
         ${EXEC_NAME}.out
         ${CMAKE_CURRENT_SOURCE_DIR}/../outputs/empty.txt
         )
endforeach(SRC)

