#!/bin/bash
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

PKG_NAME=boost
if test $CMOSS_MAC || test $CMOSS_WIN; then
    PKG_VERSION=1.58.0
else
    PKG_VERSION=1.48.0
fi
PKG_DIR_NAME=boost_${PKG_VERSION//./_}
PKG_ARCHIVE=$PKG_DIR_NAME.tar.bz2
PKG_URL=http://downloads.sourceforge.net/project/boost/boost/$PKG_VERSION

. `dirname $0`/common.sh
env_setup $@

pkg_setup $@
cd $PKG_DIR

# Apply patches to boost
${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION -t preconfig

# Build

# ---------
# Bootstrap
# ---------

if test ! -f .$PKG_NAME-inited; then
    # Make the initial bootstrap
    echo "Performing boost boostrap"

    env -i PATH="${PATH}" LANG="${LANG}" ./bootstrap.sh
    if [ $? != 0 ] ; then
        echo "ERROR: Could not perform boostrap! See $TMPLOG for more info."
        exit 1
    fi

    touch .$PKG_NAME-inited
fi

# -------------------------------------------------------------
# Patching will be done only if we had a successfull bootstrap!
# -------------------------------------------------------------

# Apply patches to boost
${TOPDIR}/patch.sh $PKG_NAME -v $PKG_VERSION

if test ! -f .$PKG_NAME-configured; then

    if test $CMOSS_ANDROID; then
        cat > tools/build/v2/user-config.jam <<EOF
using android : i686 : ${DROIDTOOLS}-g++ :
<compileflags>-Os
<compileflags>-O2
<compileflags>-g
<compileflags>-fexceptions
<cxxflags>-frtti
<compileflags>-fpic
<compileflags>-ffunction-sections
<compileflags>-funwind-tables
<compileflags>-fomit-frame-pointer
<compileflags>-fno-strict-aliasing
<compileflags>-finline-limit=64
<compileflags>-DANDROID
<compileflags>-D__ANDROID__
<compileflags>-DNDEBUG
<compileflags>-I${ROOTDIR}/include
<linkflags>-Wl,--gc-sections
<linkflags>-L${ROOTDIR}/lib
<architecture>x86
<compileflags>-fdata-sections
<cxxflags>-D_REENTRANT
<cxxflags>-D_GLIBCXX__PTHREADS
<cxxflags>-D_GLIBCXX_USE_WCHAR_T
<cxxflags>-DBOOST_THREAD_LINUX
<cxxflags>-DBOOST_HAS_PTHREADS
<cxxflags>-DBOOST_HAS_GETTIMEOFDAY
;

using android : arm : ${DROIDTOOLS}-g++ :
<compileflags>-Os
<compileflags>-O2
<compileflags>-g
<compileflags>-fexceptions
<cxxflags>-frtti
<compileflags>-fpic
<compileflags>-ffunction-sections
<compileflags>-funwind-tables
<compileflags>-march=armv5te
<compileflags>-mtune=xscale
<compileflags>-msoft-float
<compileflags>-mthumb
<compileflags>-fomit-frame-pointer
<compileflags>-fno-strict-aliasing
<compileflags>-finline-limit=64
<compileflags>-D__ARM_ARCH_5__
<compileflags>-D__ARM_ARCH_5T__
<compileflags>-D__ARM_ARCH_5E__
<compileflags>-D__ARM_ARCH_5TE__
<compileflags>-DANDROID
<compileflags>-D__ANDROID__
<compileflags>-DNDEBUG
<linkflags>-Wl,--gc-sections
<architecture>arm
<compileflags>-fdata-sections
<cxxflags>-D__arm__
<cxxflags>-D_REENTRANT
<cxxflags>-D_GLIBCXX__PTHREADS
<cxxflags>-D_GLIBCXX_USE_WCHAR_T
;
EOF
    elif test $CMOSS_WIN; then
        cat > tools/build/src/user-config.jam <<EOF
using gcc : ${PLATFORM%%-*} : ${PLATFORM}-g++ :
<compileflags>-I${PREFIX}/include
<linkflags>-Wl,--gc-sections
<linkflags>-L${PREFIX}/lib
<compileflags>-fdata-sections
;
EOF
    elif test $CMOSS_MAC; then

        MIN_IOS_VERSION=8.0
        # IOS_SDK_VERSION=`xcrun --sdk iphoneos --show-sdk-version`

        MIN_TVOS_VERSION=9.2
        # TVOS_SDK_VERSION=`xcrun --sdk appletvos --show-sdk-version`

        MIN_OSX_VERSION=10.10
        # OSX_SDK_VERSION=`xcrun --sdk macosx --show-sdk-version`

        ENABLE_BITCODE=
        # ENABLE_BITCODE="-fembed-bitcode"

        EXTRA_FLAGS="-DBOOST_AC_USE_PTHREADS -DBOOST_SP_USE_PTHREADS -g -DNDEBUG \
-fvisibility=hidden -fvisibility-inlines-hidden -Wno-unused-local-typedef $ENABLE_BITCODE"
        EXTRA_IOS_FLAGS="$EXTRA_FLAGS -mios-version-min=$MIN_IOS_VERSION"
        EXTRA_TVOS_FLAGS="$EXTRA_FLAGS -mtvos-version-min=$MIN_TVOS_VERSION"
        EXTRA_OSX_FLAGS="$EXTRA_FLAGS -mmacosx-version-min=$MIN_OSX_VERSION"

        case "$PLATFORM" in
        iPhoneOS)
        cat > tools/build/src/user-config.jam <<EOF
using darwin : ios 
: $CXX -arch $ARCH $EXTRA_IOS_FLAGS -D_LITTLE_ENDIAN
: <striper> 
<root>$DEVELOPER/Platforms/iPhoneOS.platform/Developer
<linkflags>-L${PREFIX}/lib
<compileflags>-I${PREFIX}/include
;
EOF
        ;;
        iPhoneSimulator)
        cat > tools/build/src/user-config.jam <<EOF
using darwin : iosim   
: $CXX -arch $ARCH $EXTRA_IOS_FLAGS
: <striper> 
<root>$DEVELOPER/Platforms/iPhoneSimulator.platform/Developer
<linkflags>-L${PREFIX}/lib
<compileflags>-I${PREFIX}/include
;
EOF
        ;;
        MacOSX)
        cat > tools/build/src/user-config.jam <<EOF
using darwin : osx 
: $CXX -arch $ARCH $EXTRA_OSX_FLAGS
: <striper> 
<root>$DEVELOPER/Platforms/MacOSX.platform/Developer
<linkflags>-L${PREFIX}/lib
<compileflags>-I${PREFIX}/include
;
EOF
        esac
    else
        echo unsupported platform
        exit 1
    fi

    cat > project-config.jam <<EOF
libraries = --with-date_time --with-filesystem --with-program_options --with-regex --with-signals --with-system --with-thread --with-iostreams ;
EOF

    touch .$PKG_NAME-configured
fi

case ${PLATFORM} in
*-linux-*)
    toolset="android-${PLATFORM%%-*}"
    ./b2 ${MAKE_FLAGS} threading=multi --prefix="${PREFIX}" --layout=system link=static toolset=$toolset install
    exit
    ;;
iPhoneSimulator)
    toolset="darwin-iosim"
    ;;
iPhoneOS)
    toolset="darwin-ios"
    ;;
MacOSX)
    toolset="darwin-osx"
    ;;
*-mingw32)
    # mingw cannot use system layout. It relies on Jamroot to build boost automatically
    # ./b2 ${MAKE_FLAGS} threading=multi threadapi=win32 -sNO_BZIP2=1 --prefix="${PREFIX}" --layout=tagged link=static toolset=gcc-mingw install
    exit
    ;;
esac

CXX_FLAGS="-std=c++11 -stdlib=libc++"
./b2 ${MAKE_FLAGS} cxxflags="${CXX_FLAGS}" threading=multi --layout=system \
    toolset=$toolset --prefix="${PREFIX}" link=static install

