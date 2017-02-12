#!/bin/sh
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

test -f configure || autoreconf --install
call_configure ${CONFIG_FLAGS} --disable-bsdtar --disable-bsdcat --disable-bsdcpio \
    --without-bz2lib --without-lzmadec --without-iconv --without-lz4 --without-lzo2 --without-xml2

${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION

make ${MAKE_FLAGS} 
make install
