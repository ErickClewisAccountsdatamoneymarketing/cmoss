#!/bin/sh

# static link libcurl

if [ `uname -s` = Darwin ]; then
    sed -i "" "s/curl_LDADD = /curl_LDADD = -static -fPIE -pie /g" src/Makefile
    sed -i "" "s/CFLAGS = /CFLAGS = -fPIE /g" src/Makefile
else
    sed -i "s/curl_LDADD = /curl_LDADD = -static -fPIE -pie /g" src/Makefile
    sed -i "s/CFLAGS = /CFLAGS = -fPIE /g" src/Makefile
fi
