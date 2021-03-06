#!/bin/bash
set -e
PKG_NAME=json-c
PKG_VERSION="0.11"
PKG_ARCHIVE=$PKG_NAME-$PKG_VERSION.tar.gz
PKG_URL="https://s3.amazonaws.com/json-c_releases/releases"

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

call_configure ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ${CONFIG_FLAGS}

# this library somehow fails to build with threading make
# make ${MAKE_FLAGS}
make -v
make install

