#!/bin/sh
set -e

PKG_NAME=log4c
PKG_VERSION=1.2.1
PKG_URL=http://nchc.dl.sourceforge.net/project/log4c/log4c/$PKG_VERSION

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

${TOPDIR}/helper/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

call_configure ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --without-expat --with-gnu-ld

make
make install

