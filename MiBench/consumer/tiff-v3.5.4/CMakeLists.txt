
set(TIFF_LIBDIR ${CMAKE_CURRENT_SOURCE_DIR}/libtiff)
set(TIFF_DATADIR ${CMAKE_CURRENT_SOURCE_DIR}/../tiff-data)

add_subdirectory(libtiff)
add_subdirectory(tools)

# TODO main files need to be converted to accept files from stdin and stdout
#run_io(mibench-tiff2bw_small ${CMAKE_CURRENT_BINARY_DIR}/tools/tiff2bw
#        ${TIFF_DATADIR}/small.tif
#        output_smallbw.tif
#        ${TIFF_DATADIR}/ref_smallbw.tif)
#run_io(mibench-tiff2rgba_small ${CMAKE_CURRENT_BINARY_DIR}/tools/tiff2rgba
#        ${TIFF_DATADIR}/small.tif
#        output_smallrgba.tif
#        ${TIFF_DATADIR}/ref_smallrgba.tif)
#run_io(mibench-tiff2bw_small ${CMAKE_CURRENT_BINARY_DIR}/tools/tiffdither
#        ${TIFF_DATADIR}/smallbw.tif
#        output_smalldither.tif
#        ${TIFF_DATADIR}/ref_smalldither.tif)
#run_io(mibench-tiffmedian_small ${CMAKE_CURRENT_BINARY_DIR}/tools/tiffmedian
#        ${TIFF_DATADIR}/small.tif
#        output_smallmedian.tif
#        ${TIFF_DATADIR}/ref_smallmedian.tif)
