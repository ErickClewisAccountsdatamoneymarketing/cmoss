env_setup()
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

    local self=$(readlink -f "$0")
    export TOPDIR=$(dirname $(dirname $self))
    export BINDIR=$TOPDIR/bin/droid
    export LOGDIR=$TOPDIR/log/droid
    export TMPDIR=$TOPDIR/tmp
    export DLDIR=$TOPDIR/dl
    export ROOTDIR=${ROOTDIR}
    export PLATFORM=${PLATFORM}
    export DROIDTOOLS=${TMPDIR}/droidtoolchains/${PLATFORM}/bin/${PLATFORM}
    export SYSROOT=${TMPDIR}/droidtoolchains/${PLATFORM}/sysroot

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

pkg_setup()
{
    test $PKG_DIR_NAME || PKG_DIR_NAME="$PKG_NAME-$PKG_VERSION"
    test $PKG_ARCHIVE || PKG_ARCHIVE="$PKG_NAME-$PKG_VERSION.tar.gz"

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

        if test -z $PKG_URL;then
            echo "Empty package url"
            exit 1
        fi

        case $PKG_URL_TYPE in
        svn)
            echo URL: $PKG_URL
            svn checkout $PKG_URL $PKG_DIR
            tar czf $pkg_archive -C $pkg_dir $pkg_name
            ;;
        git)
            echo URL: $PKG_URL
            git clone $PKG_URL $PKG_DIR
            if test $PKG_GIT_BRANCH; then 
                (cd $PKG_DIR; git checkout $PKG_GIT_BRANCH)
            fi
            tar czf $pkg_archive -C $pkg_dir $pkg_name
            ;;
        *)
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
