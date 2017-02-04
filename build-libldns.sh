#!/bin/sh
set -e

PKG_NAME=ldns
PKG_VERSION=1.6.17
PKG_URL=http://www.nlnetlabs.nl/downloads/ldns

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

#call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${PREFIX} --disable-gost 
call_configure ${CONFIG_FLAGS} --disable-gost --disable-dane --disable-ecdsa --without-ssl --disable-sha2 

${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

make ${MAKE_FLAGS}
make install-h install-lib install-config
