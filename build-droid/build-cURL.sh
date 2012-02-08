#!/bin/sh
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

PKG_NAME=curl
PKG_VERSION=7.23.1
PKG_URL=http://curl.haxx.se/download

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

# call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --with-zlib=${ROOTDIR} --with-ssl=${ROOTDIR} --with-libssh2=${ROOTDIR} --with-random=/dev/urandom --disable-manual --enable-ipv6
call_configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --without-ssl --without-libssh2 --with-random=/dev/urandom --disable-manual --enable-ipv6

${TOPDIR}/helper/patch.sh $PKG_NAME -v $PKG_VERSION || exit 1

make
make install

