# Cannot load a label in a bundle with another instruction 
# because the load is a long immediate.
  .globl main
main:                             
  {  add $r4 = $r0, _1
     add $r4 = $r0, 0 }
_1: