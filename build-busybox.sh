#!/bin/bash
set -e

PKG_NAME="busybox"
PKG_VERSION="1.21.0"
PKG_ARCHIVE=$PKG_NAME-$PKG_VERSION.tar.bz2
PKG_URL=http://busybox.net/downloads

. `dirname $0`/common.sh
env_setup $@
pkg_setup $@

test -d $PKG_DIR-pie || cp -a $PKG_DIR $PKG_DIR-pie

build() {
    local pie=$1
    conf=$PKG_DIR$pie/.config
    conf_check=$PKG_DIR$pie/.configured$pie
    if test ! -f $conf_check; then
        if ! cat $TOPDIR/build-droid/patches/$PKG_NAME/android.config | \
            sed "s|CONFIG_CROSS_COMPILER_PREFIX_TEMPLATE|$DROIDTOOLS-|" | \
            sed "s|CONFIG_SYSROOT_TEMPLATE|$SYSROOT|" | \
            sed "s|CONFIG_EXTRA_CFLAGS_TEMPLATE|$CFLAGS|" | \
            sed "s|CONFIG_EXTRA_LDFLAGS_TEMPLATE|$LDFLAGS $pie|" | \
            sed "s|CONFIG_EXTRA_LDLIBS_TEMPLATE||" > $conf_check; 
        then
            echo "$PKG_NAME configure failed" 
            exit 1
        fi
    fi
    if ! diff -q $conf_check $conf &> /dev/null; then
        cp $conf_check $conf
    fi

    (
        cd $PKG_DIR$pie

        ${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

        if test "$pie"; then
            prefix=${SYSROOT}/pie
        else
            prefix=${SYSROOT}
        fi
        mkdir -p $prefix

        make && \
        make CONFIG_PREFIX=$prefix install
    )
}

build 
build -pie


