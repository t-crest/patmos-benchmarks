
file(GLOB runner "test_asm.sh")
# Ensure that the runner has execute permission
execute_process(COMMAND "chmod" "+x" ${runner})

file(GLOB files "*.s")
foreach(file ${files})
  add_test( NAME ${file} 
			COMMAND ${runner} ${file} )
endforeach()
