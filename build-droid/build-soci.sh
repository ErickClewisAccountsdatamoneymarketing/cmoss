#!/bin/sh
set -e

# Copyright (c) 2011, Mevan Samaratunga
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of Mevan Samaratunga may not be used to endorse or
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

PKG_NAME=soci
PKG_VERSION="1.1.8"
PKG_ARCHIVE=soci-$PKG_VERSION.zip
PKG_URL="http://surfnet.dl.sourceforge.net/project/soci/soci"

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

# Copy customized make files
cp -f ${TOPDIR}/build-droid/patches/soci/Makefile.soci-core core/
cp -f ${TOPDIR}/build-droid/patches/soci/Makefile.soci-sqlite3 backends/sqlite3/

BIGFILES=-D_FILE_OFFSET_BITS=64
LDFLAGS="$LDFLAGS -shared"
CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64"
CXXFLAGS="CXXFLAGS -D_FILE_OFFSET_BITS=64"

make -f Makefile.soci-core -C soci-${SOCI_VERSION}/core install CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" PREFIX="${ROOTDIR}"
make -f Makefile.soci-sqlite3 -C soci-${SOCI_VERSION}/backends/sqlite3 install CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" PREFIX="${ROOTDIR}"

