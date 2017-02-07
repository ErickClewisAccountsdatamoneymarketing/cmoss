env_setup()
{
    case "`uname -s`" in
    Darwin)
        os="mac"
        ;;
    Linux)
        os="linux"
        ;;
    *)
        echo unsupported os
        exit 1
        ;;
    esac

    export MAKE_FLAGS="-j4"

    if [ "$os" = "mac" ]; then
        env_setup_mac
    else
        env_setup_linux
    fi
}

env_setup_linux()
{
    local target=
    for arg in $@; do
        case $arg in
        x86|arm)
            target=$arg;;
        esac
    done
    test $target || target=arm

    case $target in
        x86)
            export PLATFORM="i686-linux-android"
            export ARCH="x86"
            export TC_PLATFORM=$ARCH
            ;;
        arm)
            export PLATFORM="arm-linux-androideabi"
            export ARCH="armv7"
            export TC_PLATFORM=$PLATFORM
            ;;
        *)
            echo "Unknown target: $target">&2
            exit 1
            ;;
    esac

    ANDROID_API_LEVEL="14"
    TOOLCHAIN_VERSION="4.9"
    export TOPDIR=$PWD
    export BINDIR=$TOPDIR/bin/droid
    export LOGDIR=$TOPDIR/log/droid
    export TMPDIR=$TOPDIR/tmp
    export DLDIR=$TOPDIR/dl
    export PLATFORM=${PLATFORM}
    export CONFIG_FLAGS="--host=$ARCH-android-linux --target=${PLATFORM} --prefix=${PREFIX}"
    export DROIDTOOLS=${TMPDIR}/droidtoolchains/${PLATFORM}/bin/${PLATFORM}
    export SYSROOT=${TMPDIR}/droidtoolchains/${PLATFORM}/sysroot
    export PREFIX=${SYSROOT}/usr

    export LOGPATH="${LOGDIR}/${PLATFORM}"
    export ROOTDIR="${TMPDIR}/build/droid/${PLATFORM}"
    mkdir -p "${ROOTDIR}"
    mkdir -p $DLDIR

    if [ ! -d "${TMPDIR}/droidtoolchains/${PLATFORM}" ]; then
        test $ANDROID_NDK || ANDROID_NDK="$TOPDIR/build-droid/android-ndk"

        if test ! -e ${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh; then
            echo "Invalid NDK: $ANDROID_NDK" >&2
            exit 1
        fi

        echo "Creating toolchain for platform ${PLATFORM}..."
        ${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh \
            --verbose \
            --platform=android-${ANDROID_API_LEVEL} \
            --toolchain=${TC_PLATFORM}-${TOOLCHAIN_VERSION} \
            --install-dir=${TMPDIR}/droidtoolchains/${PLATFORM}
    fi

    export CC=${DROIDTOOLS}-gcc
    export LD=${DROIDTOOLS}-ld
    export CPP=${DROIDTOOLS}-cpp
    export CXX=${DROIDTOOLS}-g++
    export AR=${DROIDTOOLS}-ar
    export AS=${DROIDTOOLS}-as
    export NM=${DROIDTOOLS}-nm
    export STRIP=${DROIDTOOLS}-strip
    export CXXCPP=${DROIDTOOLS}-cpp
    export RANLIB=${DROIDTOOLS}-ranlib
    export LDFLAGS="-Os -pipe -isysroot ${SYSROOT} -L${ROOTDIR}/lib"
    export CFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"
    export CXXFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"
    export LDFLAGS_CPP="-nostdlib -lc -Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -L${ROOTDIR}/lib"
}

env_setup_mac()
{
    local platform=
    for arg in $@; do
        case $arg in
        ios*)
            platform=iPhoneOS-V${arg#ios};;
        sim)
            platform=iPhoneSimulator;;
        mac)
            platform=MacOS;;
        esac
    done
    test $platform || platform=iPhoneOS-V9

    host_arch="x86_64"

    MIN_VERSION=
    case $platform in
        iPhoneSimulator)
		    export PLATFORM="iPhoneSimulator"
            export ARCH_FAT=(i386 x86_64)
            export CONFIG_FLAGS="--host=i386-apple-darwin"
            ;;
        iPhoneOS*)
            MIN_VERSION="-miphoneos-version-min=7.0"
		    export PLATFORM="iPhoneOS"
            export ARCH_FAT=(armv7 arm64)
            export CONFIG_FLAGS="--host=arm-apple-darwin"
            ;;
        MacOS)
		    export PLATFORM="MacOSX"
            export ARCH_FAT=(i386 x86_64)
            export CONFIG_FLAGS="--host=$host_arch-apple-darwin"
            ;;
        *)
            echo "Unknown platform: $platform">&2
            exit 1
            ;;
    esac

    export ARCH_COUNT=${#ARCH_FAT[@]}
    if test $ARCH_IDX; then
        export ARCH=${ARCH_FAT[$ARCH_IDX]}
    else
        export ARCH=${ARCH_FAT[0]}
    fi

    export DEVELOPER=`xcode-select --print-path`
    export TOPDIR=$PWD
    export BINDIR=$TOPDIR/bin/mac
    export LOGDIR=$TOPDIR/log/mac
    export TMPDIR=$TOPDIR/tmp
    export DLDIR=$TOPDIR/dl
    export PLATFORM=${PLATFORM}
    export LOGPATH="${LOGDIR}/${PLATFORM}/$ARCH"
    export ROOTDIR="${TMPDIR}/build/mac/${PLATFORM}/$ARCH"
    mkdir -p "${ROOTDIR}/bin"
    mkdir -p "${ROOTDIR}/include"
    mkdir -p "${ROOTDIR}/lib"
    mkdir -p $DLDIR

    BIGFILES="-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE"
    export DEVROOT="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
    export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}.sdk"
    export MACTOOLS="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
    export PREFIX=${ROOTDIR}
    export CC=${MACTOOLS}/cc
    export LD=${MACTOOLS}/ld
    # export CPP=${MACTOOLS}/cpp
    export CXX=${MACTOOLS}/c++
    export AR=${MACTOOLS}/ar
    export AS=${MACTOOLS}/as
    export NM=${MACTOOLS}/nm
    # export CXXCPP=${MACTOOLS}/cpp
    export RANLIB=${MACTOOLS}/ranlib
    export LDFLAGS="-Os -arch $ARCH -Wl,-dead_strip ${MIN_VERSION} -L${ROOTDIR}/lib"
    export CFLAGS="-Os -arch $ARCH -pipe -no-cpp-precomp ${MIN_VERSION} -isysroot ${SDKROOT} -I${ROOTDIR}/include -g ${BIGFILES} -Wno-error=implicit-function-declaration"
    export CXXFLAGS="${CFLAGS}"
    export CPPFLAGS="${CFLAGS}"

    CONFIG_FLAGS="$CONFIG_FLAGS --build=$host_arch-apple-darwin --prefix=$PREFIX"

    cp -n $DEVELOPER/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/include/{crt_externs,bzlib}.h $ROOTDIR/include || true
}

check_url() {
    if test -z $PKG_URL;then
        echo "Empty package url"
        exit 1
    fi
}

pkg_setup()
{
    test $PKG_DIR_NAME || PKG_DIR_NAME="$PKG_NAME-$PKG_VERSION"
    test $PKG_ARCHIVE || PKG_ARCHIVE="$PKG_NAME-$PKG_VERSION.tar.gz"

    echo mkdir $ROOTDIR/src
    mkdir -p $ROOTDIR/src
    PKG_DIR="$ROOTDIR/src/$PKG_DIR_NAME"

    local arg=
    for arg in $@; do
        if [ "$arg" = "clean" ]; then
            rm -rf $PKG_DIR
            exit 0
        fi
    done

    local pkg_dir=`dirname $PKG_DIR`
    local pkg_name=`basename $PKG_DIR`
    local pkg_archive=$DLDIR/$PKG_ARCHIVE

    if [ ! -e  $pkg_archive ]; then
        rm -rf $PKG_DIR

        case $PKG_URL_TYPE in
        depot)
            if ! which gclient; then
                if ! test -e $DLDIR/depot_tools/gclient; then
                    rm -rf $DLDIR/depot_tools
                    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DLDIR/depot_tools
                fi
                PATH=$DLDIR/depot_tools:$PATH
            fi
            rm -rf $DLDIR/depot
            mkdir -p $DLDIR/depot
            (
                cd $DLDIR/depot;
                fetch $PKG_NAME;
                test $PKG_GIT_BRANCH && cd src && git checkout $PKG_GIT_BRANCH && gclient sync && cd ..;
                mv src $PKG_DIR;
            )
            tar czf $pkg_archive -C $pkg_dir $pkg_name
            ;;
        svn)
            check_url
            echo URL: $PKG_URL
            svn checkout $PKG_URL $PKG_DIR
            tar czf $pkg_archive -C $pkg_dir $pkg_name
            ;;
        git)
            check_url
            echo URL: $PKG_URL
            git clone $PKG_URL $PKG_DIR
            if test $PKG_GIT_BRANCH; then 
                (cd $PKG_DIR; git checkout $PKG_GIT_BRANCH)
            fi
            tar czf $pkg_archive -C $pkg_dir $pkg_name
            ;;
        *)
            check_url
            echo URL: $PKG_URL/$PKG_ARCHIVE
            (cd `dirname $pkg_archive`; wget "$PKG_URL/$PKG_ARCHIVE")
            tar xf $pkg_archive -C $pkg_dir
            ;;
        esac
    elif test ! -d $PKG_DIR; then
        if [ "${PKG_ARCHIVE##*\.}" = "zip" ]; then
            unzip "$pkg_archive" -d $pkg_dir
        else
            tar xf "$pkg_archive" -C $pkg_dir
        fi
    fi
}

call_configure()
{
    if test ! -f .$PKG_NAME-configured; then
        if test -e ./configure; then
            configure=./configure
        else
            configure=./Configure
        fi
        if ! $configure "$@"; then
            exit 1
        fi
        touch .$PKG_NAME-configured
    fi
}
