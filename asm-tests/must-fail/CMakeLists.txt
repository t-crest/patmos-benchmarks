
file(GLOB runner "test_asm.sh")
file(GLOB files "*.s")
foreach(file ${files})
  add_test( NAME ${file} 
			COMMAND ${runner} ${file} )
endforeach()