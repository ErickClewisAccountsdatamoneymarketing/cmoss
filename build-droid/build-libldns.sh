#!/bin/sh
set -e

PKG_NAME=ldns
PKG_VERSION=1.6.16
PKG_URL=http://www.nlnetlabs.nl/downloads/ldns

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

LDFLAGS="-Os -pipe -isysroot ${SYSROOT} -L${ROOTDIR}/lib"

call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --disable-gost --with-ssl=${ROOTDIR} 
call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --disable-gost --disable-ecdsa --without-ssl --disable-sha2 

make
make install
