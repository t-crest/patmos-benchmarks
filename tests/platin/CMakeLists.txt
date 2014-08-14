set(testfiles
   02-clang-flowfact
   03-clang-loopbound-pragma
   22-call-any
   )

set(anno-02-clang-flowfact true)
set(wcet-03-clang-loopbound-pragma true)
set(pmlmod-22-call-any "--match \"/*/[@label=main]/*/*\" --clear-callees")

foreach(test ${testfiles})
   add_executable(${test} ${test}.c)

   if(DEFINED anno-${test})
      add_custom_command(TARGET ${test}
         PRE_BUILD
         COMMAND ${CLANG_EXECUTABLE} -cc1 -triple ${TRIPLE} -ff-export=${test}.ff.pml ${CMAKE_CURRENT_SOURCE_DIR}/${test}.c)
   endif(DEFINED anno-${test})

   if(DEFINED wcet-${test} OR DEFINED anno-${test})
      get_target_config(${test} config_pml)
      set(pml_inputs "--input ${config_pml} --input ${test}.pml")
      if(DEFINED anno-${test})
         set(pml_inputs "${pml_inputs} --input ${test}.ff.pml")
      endif()
      separate_arguments(pml_inputs)
      add_test(NAME platin-wcet-${test} COMMAND ${PLATIN_EXECUTABLE} wcet ${PLATIN_WCA_TOOL} ${PLATIN_OPTIONS}
                                                           ${pml_inputs}
                                                           --binary ${test}
                                                           )
   endif()

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

