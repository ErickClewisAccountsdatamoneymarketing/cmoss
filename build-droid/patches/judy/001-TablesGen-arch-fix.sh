#!/bin/bash
if [ ${PLATFORM#*64} = "$PLATFORM" ]; then
    # when build for 32bit platform on 64bit host, we must
    # force gcc to build 32bit
    sed -i "s/gcc/gcc -m32/g" src/Judy1/Makefile.in
    sed -i "s/gcc/gcc -m32/g" src/JudyL/Makefile.in
fi
