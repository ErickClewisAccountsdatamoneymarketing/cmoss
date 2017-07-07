#!/bin/bash
set -e

PKG_NAME=judy
PKG_VERSION=1.0.5
PKG_ARCHIVE=Judy-$PKG_VERSION.tar.gz
PKG_URL=http://nchc.dl.sourceforge.net/project/judy/judy/Judy-$PKG_VERSION

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION

if [ ${ARCH/64} != $ARCH ]; then
    # CFLAGS="${CFLAGS} -DJU_64BIT"
    CONFIG_FLAGS="$CONFIG_FLAGS --enable-64-bit --disable-32-bit"
else
    CONFIG_FLAGS="$CONFIG_FLAGS --disable-64-bit --enable-32-bit"
fi

call_configure ${CONFIG_FLAGS}

make ${MAKE_FLAGS}
make install

