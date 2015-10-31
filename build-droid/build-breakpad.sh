#!/bin/bash
set -e

PKG_NAME=breakpad
#PKG_VERSION=735
PKG_VERSION=1457
PKG_URL_TYPE=svn
PKG_URL=http://google-breakpad.googlecode.com/svn/trunk@$PKG_VERSION

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${SYSROOT}/usr --disable-processor --disable-tools

${TOPDIR}/helper/patch.sh ${PKG_NAME} -v ${PKG_VERSION} || exit 1

make && \
make install

