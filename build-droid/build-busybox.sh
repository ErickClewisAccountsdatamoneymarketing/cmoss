#!/bin/bash
set -e

PKG_NAME="busybox"
PKG_VERSION="1.21.0"
PKG_ARCHIVE=$PKG_NAME-$PKG_VERSION.tar.bz2
PKG_URL=http://busybox.net/downloads

. `dirname $0`/common.sh
env_setup $@
pkg_setup $@

conf=$PKG_DIR/.config
conf_check=$PKG_DIR/.configured$ANDROID_BUILD_PIE
if test ! -f $conf_check; then
    if ! cat $TOPDIR/build-droid/patches/$PKG_NAME/android.config | \
        sed "s|CONFIG_CROSS_COMPILER_PREFIX_TEMPLATE|$DROIDTOOLS-|" | \
        sed "s|CONFIG_SYSROOT_TEMPLATE|$SYSROOT|" | \
        sed "s|CONFIG_EXTRA_CFLAGS_TEMPLATE|$CFLAGS|" | \
        sed "s|CONFIG_EXTRA_LDFLAGS_TEMPLATE|$LDFLAGS $ANDROID_BUILD_PIE|" | \
        sed "s|CONFIG_EXTRA_LDLIBS_TEMPLATE||" > $conf_check; 
    then
        echo "$PKG_NAME configure failed" 
        exit 1
    fi
fi
if ! diff -q $conf_check $conf &> /dev/null; then
    cp $conf_check $conf
fi

cd $PKG_DIR

${TOPDIR}/helper/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

prefix=${SYSROOT}/usr$ANDROID_BUILD_PIE
mkdir -p $prefix

make && \
make CONFIG_PREFIX==$prefix install

