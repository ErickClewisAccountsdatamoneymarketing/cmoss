#!/bin/sh

# static link libcurl

sed -i "s/curl_LDADD = /curl_LDADD = -static -fPIE -pie /g" src/Makefile
sed -i "s/CFLAGS = /CFLAGS = -fPIE /g" src/Makefile
