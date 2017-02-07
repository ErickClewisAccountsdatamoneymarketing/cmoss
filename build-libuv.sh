#!/bin/sh
set -e

PKG_NAME="libuv"
PKG_VERSION="1.11.0"
PKG_GIT_BRANCH="v$PKG_VERSION"
PKG_URL_TYPE=git
PKG_URL=https://github.com/libuv/libuv

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

test -f configure || ./autogen.sh
call_configure ${CONFIG_FLAGS}

${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION

make ${MAKE_FLAGS} 
make install
