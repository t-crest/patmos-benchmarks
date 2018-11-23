#!/bin/bash -e
if ! test -e "$1"; then
	echo "Couldn't find file '$1'"
	exit 1
fi

if patmos-clang "$1" -o "$1".o; then
	echo "The compilation succeeded, which it shouldn't have: '$1'"
	rm "$1".o
	exit 1
else
	echo "The complation failed, as is intended."
	exit 0
fi
