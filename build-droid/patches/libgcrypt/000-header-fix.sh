#!/bin/sh

mv "src/gcrypt.h" "src/gcrypt.h~"
sed 's/#include <sys\/types.h>/#include <sys\/select.h>\
#include <sys\/types.h>/' src/gcrypt.h~ > src/gcrypt.h
