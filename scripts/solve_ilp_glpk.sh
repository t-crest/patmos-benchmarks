#!/bin/bash

# This is a wrapper script for the GLPK ILP solver as used by the stack cache
# analysis in Patmos LLVM.
# Input: an ILP in CPLEX .lp format
# Output: .sol file containing the objective value (or an error status)

# glpk has an issue with the constraint name 'en:' (thinks it's end), so we
# mangle the constraint names in the .lp file first
sed -i -e 's/\(.*\):/glp.\1:/' $1

GLPSOL=`glpsol --lp $1`;

STATUS=`printf "%s\n" "$GLPSOL" | grep "INTEGER OPTIMAL SOLUTION FOUND"`
RESULT=`printf "%s\n" "$GLPSOL" | grep "obj.="`
UNBOUND=`printf "%s\n" "$GLPSOL" | grep "PROBLEM HAS UNBOUNDED SOLUTION"`

if [ -n "${UNBOUND}" ]; then
  echo -1 > $1.sol;
elif [ -z "${STATUS}" ]; then
  exit 1
else
  echo ${RESULT} | cut -d = -f 2 | sed -e 's/infeas//' > $1.sol
fi


exit 0
