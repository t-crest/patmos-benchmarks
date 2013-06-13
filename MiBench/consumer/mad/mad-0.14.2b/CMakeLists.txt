
add_subdirectory(libmad)
add_subdirectory(libid3tag)
add_subdirectory(libz)

add_executable(madplay  version.c audio.c audio_cdda.c audio_aiff.c 
			audio_wave.c audio_snd.c audio_raw.c audio_null.c madplay.c resample.c 
			filter.c equalizer.c xing.c player.c getopt.c getopt1.c)

target_link_libraries(madplay libmad libid3tag libz m)

