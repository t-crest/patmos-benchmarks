set(testfiles
   02-clang-annotation
   22-call-any
   )

set(pmlmod-22-call-any "--match \"/*/[@label=main]/*/*\" --clear-callees")
set(anno-02-clang-annotation "foobar")

foreach(test ${testfiles})
   add_executable(${test} ${test}.c)

   if(DEFINED anno-${test})
      add_custom_command(TARGET ${test}
         PRE_BUILD
         COMMAND ${CLANG_EXECUTABLE} -cc1 -triple ${TRIPLE} -ff-export=${test}.ff.pml ${CMAKE_CURRENT_SOURCE_DIR}/${test}.c)

      get_target_config(${test} config_pml)
      add_test(NAME platin-wcet-${test} COMMAND ${PLATIN_EXECUTABLE} wcet ${PLATIN_WCA_TOOL} ${PLATIN_OPTIONS}
                                                           --input ${config_pml} --input ${test}.pml
                                                           --input ${test}.ff.pml
                                                           --binary ${test}
                                                           )
   endif(DEFINED anno-${test})

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
