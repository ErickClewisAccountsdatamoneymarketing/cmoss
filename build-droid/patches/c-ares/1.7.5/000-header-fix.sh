#!/bin/sh

# Fix ares.h to compile on linux based systems
mv "ares.h" "ares.h~"
sed 's/#include <sys\/types.h>/#include <sys\/select.h>\
#include <sys\/types.h>/' ares.h~ > ares.h

# Fix ares_config.h file
mv "ares_config.h" "ares_config.h~"
sed 's/#define HAVE_ARPA_NAMESER_H 1//' ares_config.h~ > ares_config.h

