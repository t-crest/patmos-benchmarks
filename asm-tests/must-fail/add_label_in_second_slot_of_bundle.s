# A label load cannot be the second instruction in a bundle
# because the load is a long immediate.
  .globl main
main:                             
  {  add $r4 = $r0, 0
     add $r4 = $r0, _1 }
_1: