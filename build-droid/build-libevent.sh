#!/bin/sh
set -e

PKG_NAME="libevent"
PKG_VERSION="2.0.18-stable"
PKG_ARCHIVE=libevent-$PKG_VERSION.tar.gz
PKG_URL=https://github.com/downloads/libevent/libevent

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR
call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR}

make
make install
