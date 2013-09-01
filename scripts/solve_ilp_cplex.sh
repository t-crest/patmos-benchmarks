#!/bin/bash

# This is a wrapper script for the CPLEX ILP solver as used by the stack cache
# analysis in Patmos LLVM.
# Input: an ILP in CPLEX .lp format
# Output: .sol file containing the objective value (or an error status)

RESULT=`echo -e "read $1\nmipopt\nquit\n" | cplex | grep "MIP - " | head -n1`;

if [ -z "${RESULT}" ]; then
  exit 1
elif [ "${RESULT}" == "MIP - Integer infeasible or unbounded." ]; then
  echo -1 > $1.sol;
else
  echo ${RESULT} | cut -d = -f 2 > $1.sol
fi

exit 0
