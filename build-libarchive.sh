#!/bin/bash
set -e

PKG_NAME="libarchive"
PKG_VERSION="3.2.2"
PKG_GIT_BRANCH="v$PKG_VERSION"
PKG_URL_TYPE=git
PKG_URL=https://github.com/libarchive/libarchive

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

test -f configure || build/autogen.sh

test "$CMOSS_ANDROID" && \
    export CFLAGS="-Icontrib/android/include $CFLAGS"

call_configure ${CONFIG_FLAGS} --disable-bsdtar --disable-bsdcat --disable-bsdcpio --without-openssl\
    --without-bz2lib --without-lzmadec --without-iconv --without-lz4 --without-lzo2 --without-xml2

${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION

make ${MAKE_FLAGS} 
make install

if test "$CMOSS_ANDROID"; then
    cp -u contrib/android/include/android_lf.h $PREFIX/include
fi
