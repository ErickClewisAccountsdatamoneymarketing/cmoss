#!/bin/bash
set -e

# Copyright (c) 2010, Pierre-Olivier Latour
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of Pierre-Olivier Latour may not be used to endorse or
#       promote products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

PKG_NAME=openssl
PKG_VERSION="1.1.0e"
PKG_URL=http://www.openssl.org/source

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

if test "$CMOSS_MAC"; then
    SDK_COMPONENTS=($(echo ${SDKROOT} | sed -e 's/\/SDKs\//\'$'\n/'))
    export CROSS_TOP="${SDK_COMPONENTS[0]}"
    export CROSS_SDK="${SDK_COMPONENTS[1]}"
    args=
    case $ARCH in
    i386)
        args="no-shared no-asm darwin-i386-cc";;
    x86_64)
        args="no-shared no-asm enable-ec_nistp_64_gcc_128 darwin-x86_64-cc";;
    arm64)
        args="no-shared no-async zlib-dynamic enable-ec_nistp_64_gcc_128 ios64-cross";;
    armv7)
        args="no-shared no-async zlib-dynamic ios-cross";;
    *)
        echo unsupported arch $ARCH
        exit 1
    esac
    call_configure --prefix=${PREFIX} $args
    make ${MAKE_FLAGS} CC="${CC}" CFLAG="${CFLAGS}" SHARED_LDFLAGS="${LDFLAGS}"
elif test "$CMOSS_ANDROID"; then
    export CROSS_SYSROOT="${SYSROOT}"
    args=
    case $ARCH in
    armv7)
        args="android-armeabi";;
    x86)
        args="android-x86";;
    *)
        echo unsupported arch $ARCH
        exit 1
    esac
    call_configure --prefix=${PREFIX} $args
    make ${MAKE_FLAGS}
elif test "$CMOSS_WIN"; then
    args=
    case $ARCH in
    i686)
        args="mingw";;
    x86_64)
        args="mingw64";;
    *)
        echo unsupported arch $ARCH
        exit 1
    esac
    call_configure --prefix=${PREFIX} $args
    make ${MAKE_FLAGS}
else
    echo "unknown target"
    exit 1
fi

make install_sw
