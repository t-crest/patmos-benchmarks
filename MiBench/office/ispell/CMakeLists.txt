
# TODO add bison/yacc for parse.y
# TODO support dirent.h in newlib for patmos, or find a way to get by without it
# TODO autogenerate config.h

#add_executable(buildhash buildhash.c hash.c makedent.c parse.y)
#add_executable(icombine  icombine.c makedent.c parse.y)
add_executable(ijoin     ijoin.c fields.c)
add_executable(ispell    term.c ispell.c correct.c defmt.c dump.c good.c lookup.c
                         hash.c makedent.c tgood.c tree.c xgets.c)
add_executable(sq	 sq.c)
add_executable(unsq      unsq.c)

#run_io(mibench-ispell_small ${CMAKE_CURRENT_BINARY_DIR}/ispell
#        tests/small.txt
#        output_small.au
#        ${CMAKE_CURRENT_BINARY_DIR}/tests/ref_small.au)

