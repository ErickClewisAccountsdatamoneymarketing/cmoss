#!/bin/sh

sed "s/Wl,-rpath/Wl,--entry=main,-rpath/g" src/Makefile > src/.Makefile.tmp
mv src/.Makefile.tmp src/Makefile
