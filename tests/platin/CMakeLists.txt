set(testfiles
   22-call-any
   )

set(pmlmod-22-call-any "--match \"/*/[@label=main]/*/*\" --clear-callees")

foreach(test ${testfiles})
   add_executable(${test} ${test}.c)

   if(DEFINED pmlmod-${test})
      set(modopts ${pmlmod-${test}})
      separate_arguments(modopts)
      # post-process PML, removing problematic calls
      add_custom_command(TARGET ${test}
         POST_BUILD
         COMMAND ${PLATIN_EXECUTABLE} pmlmod ${modopts} --clear-callees -i ${test}.pml -o ${test}.pml)
   endif()

   add_test(NAME platin-viztest-${test}
      COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/test-visualize.rb ${test}.pml)
endforeach()
