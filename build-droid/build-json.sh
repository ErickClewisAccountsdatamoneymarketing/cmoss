#!/bin/sh
set -e
PKG_NAME=json-c
PKG_VERSION="0.11"
PKG_ARCHIVE=$PKG_NAME-$PKG_VERSION.tar.gz
PKG_URL="https://s3.amazonaws.com/json-c_releases/releases"

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${SYSROOT}/usr

make
make install

