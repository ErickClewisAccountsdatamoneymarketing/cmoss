#!/bin/sh

if [ `uname -s` = Darwin ]; then
    sed -i "" "s/Wl,-rpath/Wl,--entry=main,-rpath/g" src/Makefile
    sed -i "" "s|#define HAVE_STRLCAT 1|/*#undef HAVE_STRLCAT*/|g" src/curl_config.h
    sed -i "" "s|#define HAVE_STRLCAT 1|/*#undef HAVE_STRLCAT*/|g" lib/curl_config.h
else
    sed -i "s/Wl,-rpath/Wl,--entry=main,-rpath/g" src/Makefile
fi
