
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(SAY_SOURCE say.c saynum.c darray.c ASCII.c phones.c text.c english.c trie.c phtoelm.c 
               holmes.c elements.c nsynth.c def_pars.c l2u.c aufile.c  dict.c
	       getarg.c Revision.c)

add_executable(say       ${SAY_SOURCE} config/dummyplay.c)

# requires audio/audiolib.h
#add_executable(nasay     ${SAY_SOURCE} naplay.c)
# requires gdbm.h
#add_executable(dlookup   dlookup.c phones.c dict.c getarg.c)
#add_executable(mkdictdb  mkdictdb.c trie.c phones.c)

target_link_libraries(say m)

run_io(mibench-say_tiny ${CMAKE_CURRENT_BINARY_DIR}/say
        ${CMAKE_CURRENT_SOURCE_DIR}/tinyinput.txt
        tiny_output.au
        ${CMAKE_CURRENT_SOURCE_DIR}/ref_tiny.au)

# Takes too long
#run_io(mibench-say ${CMAKE_CURRENT_BINARY_DIR}/say
#        ${CMAKE_CURRENT_SOURCE_DIR}/smallinput.txt
#        small_output.au
#        ${CMAKE_CURRENT_SOURCE_DIR}/ref_small.au)

#set_sca_options(say ${CMAKE_CURRENT_SOURCE_DIR}/../../recursion.lp)
#make_ais(sca_platin-say ${CMAKE_CURRENT_BINARY_DIR}/say ${CMAKE_CURRENT_BINARY_DIR}/say.pml)

