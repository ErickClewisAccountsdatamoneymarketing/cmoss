#!/bin/bash
set -e

PKG_NAME=breakpad

if [ `uname -s` = Darwin ]; then
    PKG_URL_TYPE=git
    PKG_URL=https://github.com/sleroux/google-breakpad-ios
    PKG_GIT_BRANCH=caf2355bc5ecab6d43ed1cfb1cdb5b06d7e8cdbf
    PKG_VERSION=caf2355b
else
    #PKG_VERSION=735
    #PKG_VERSION=1457
    #PKG_URL_TYPE=svn
    # PKG_URL=http://google-breakpad.googlecode.com/svn/trunk@$PKG_VERSION

    PKG_URL_TYPE=depot
    PKG_GIT_BRANCH=5c42d7288a175f6d976ec0d90ced688aacd0d8b3
    PKG_VERSION=5c42d728
fi

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

call_configure ${CONFIG_FLAGS} --disable-processor --disable-tools

${TOPDIR}/patch.sh ${PKG_NAME} -v ${PKG_VERSION}

make ${MAKE_FLAGS}
make install

