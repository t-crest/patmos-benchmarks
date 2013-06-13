
add_library(mp3lame STATIC  brhist.c formatBitstream.c fft.c get_audio.c l3bitstream.c id3tag.c ieeefloat.c lame.c newmdct.c
                            parse.c portableio.c psymodel.c quantize.c quantize-pvt.c vbrquantize.c reservoir.c 
                            tables.c takehiro.c timestatus.c util.c VbrTag.c version.c gtkanal.c 
                            gpkplotting.c mpglib/common.c mpglib/dct64_i386.c mpglib/decode_i386.c 
                            mpglib/layer3.c mpglib/tabinit.c mpglib/interface.c mpglib/main.c)

add_definitions(-DLAMEPARSE -DLAMESNDFILE)

add_executable(lame main.c)
#add_executable(mp3x mp3x.c)
#add_executable(mp3rtp mp3rtp.c rtp.c)

target_link_libraries(lame mp3lame m)
#target_link_libraries(mp3x mp3lame m)
#target_link_libraries(mp3rtp mp3lame m)
