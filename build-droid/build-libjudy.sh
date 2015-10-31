#!/bin/sh
set -e

PKG_NAME=judy
PKG_VERSION=1.0.5
PKG_ARCHIVE=Judy-$PKG_VERSION.tar.gz
PKG_URL=http://nchc.dl.sourceforge.net/project/judy/judy/Judy-$PKG_VERSION

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

${TOPDIR}/helper/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${SYSROOT}/usr

make && \
make install

