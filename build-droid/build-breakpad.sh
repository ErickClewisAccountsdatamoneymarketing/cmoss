#!/bin/bash
set -e

PKG_NAME=breakpad

#PKG_VERSION=735
#PKG_VERSION=1457
#PKG_URL_TYPE=svn
# PKG_URL=http://google-breakpad.googlecode.com/svn/trunk@$PKG_VERSION

PKG_URL_TYPE=depot
PKG_GIT_BRANCH=5c42d7288a175f6d976ec0d90ced688aacd0d8b3
PKG_VERSION=5c42d728

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${SYSROOT}/usr --disable-processor --disable-tools

${TOPDIR}/helper/patch.sh ${PKG_NAME} -v ${PKG_VERSION} || exit 1

make
make install

