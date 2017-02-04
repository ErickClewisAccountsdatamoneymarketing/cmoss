#!/bin/sh
set -e

PKG_NAME="libevent"
PKG_VERSION="2.0.22-stable"
PKG_ARCHIVE=release-$PKG_VERSION.tar.gz
PKG_DIR_NAME=Libevent-release-$PKG_VERSION
PKG_URL=https://github.com/nmathewson/Libevent/archive

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR
test -f configure || ./autogen.sh
call_configure ${CONFIG_FLAGS}

${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

make ${MAKE_FLAGS}
make install
