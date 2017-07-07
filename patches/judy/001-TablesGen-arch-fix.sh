#!/bin/bash

# when build for 32bit platform on 64bit host, we must force gcc to build
# 32bit, hence the -m32 option

if [ `uname -s` = 'Darwin' ]; then
    gcc_op=
    if [ ${ARCH/64} = "$ARCH" ]; then
        gcc_op=' -m32'
    else
        gcc_op=' -DJU_64BIT'
    fi
    # Tablegen is going to run one the build system.  We need native code. When
    # on macos, use env -i to sanitze envrinonement, otherwise ios sdk will be
    # used
    for f in Judy1 JudyL; do
        sed -i "" "s/gcc/env -i PATH='\${PATH}' LANG='\${LANG}' gcc${gcc_op}/g" src/$f/Makefile.in
    done
elif [ ${ARCH/64} = "$ARCH" ]; then
    sed -i "s/gcc/gcc -m32/g" src/Judy1/Makefile.in
    sed -i "s/gcc/gcc -m32/g" src/JudyL/Makefile.in
fi
