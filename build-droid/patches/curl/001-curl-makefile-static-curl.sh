#!/bin/sh

# static link libcurl

sed "s/curl_LDADD = /curl_LDADD = -static /g" src/Makefile > src/.Makefile.tmp
mv src/.Makefile.tmp src/Makefile
