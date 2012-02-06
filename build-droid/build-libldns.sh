#!/bin/sh
set -e

PKG_NAME=ldns
PKG_VERSION=1.6.11
PKG_URL=http://www.nlnetlabs.nl/downloads/ldns

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

LDFLAGS="-Os -pipe -isysroot ${SYSROOT} -L${ROOTDIR}/lib"

call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --with-ssl=${ROOTDIR} --disable-gost

make
make install