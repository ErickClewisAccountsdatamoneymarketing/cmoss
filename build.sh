#!/bin/bash
set -e

# Package list
# A simplistic way of defining dependency by ording, Makefile would be better
packages="\
    openssl \
    json \
    libuv \
    libevent \
    cares \
    bzip2 \
    libgpg-error \
    libgcrypt \
    GnuPG \
    expat \
    libssh2 \
    libldns \
    cURL \
    soci \
    sqlcipher \
    yajl \
    liblog4c \
    boost \
    breakpad \
    libjudy \
    libarchive \
    busybox \
"
default_linux="\
    breakpad \
    libevent \
    bzip2 \
    expat \
    liblog4c \
    cURL \
    boost \
    libldns \
    libjudy \
    json \
    openssl \
    busybox \
    libuv \
    libarchive \
"
target_linux=arm

default_mac="\
    libevent \
    liblog4c \
    boost \
    libldns \
    libjudy \
    json \
    expat \
    openssl \
    libuv \
    libarchive \
"
target_mac=ios9

default_win="\
    libevent \
    liblog4c \
    boost \
    libldns \
    libjudy \
    expat \
    openssl \
    libuv \
    libarchive \
"
target_win=mingw

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

export CMOSS_TARGET_OS=$os

for p in ${packages[@]}; do
    declare PKG_${p//[-.]/_}=0
done

base_path=`dirname $0`

targets=
clean=
remove_shared=
export CMOSS_DEBUG=
for arg in "$@" ; do
    case $arg in
        debug)
            export CMOSS_DEBUG=1
            ;;
        mingw|mingw64)
            export CMOSS_TARGET_OS=win
            export targets="$targets $arg"
            ;;
        ios*|mac|sim)
            remove_shared=1
            export targets="$targets $arg"
            ;;
        x86|arm)
            export targets="$targets $arg"
            ;;
        clean)
            clean=clean
            ;;
        all)
            for p in $packages; do
                declare PKG_${p//[-.]/_}=1
            done
            ;;
        default)
            for p in ${!default}; do
                var=PKG_${p//[-.]/_}
                declare $var=1
            done
            ;;
        *)
            var=PKG_${arg//[-.]/_}
            if test ! -f $base_path/build-$arg.sh || test -z ${!var}; then
                echo "Package $arg not found" >&2
                exit 1
            fi
            declare $var=1
            ;;
    esac
done

default=default_$CMOSS_TARGET_OS
target_default=target_$CMOSS_TARGET_OS

test $targets || targets=${!target_default}

. `dirname $0`/common.sh

for t in $targets; do

    ARCH_COUNT=0
    export ARCH_IDX=0
    env_setup $t

    for p in $packages; do
        var=PKG_${p//[-.]/_}
        [ "${!var}" = "1" ] || continue

        ARCH_IDX=0
        while ((ARCH_IDX<ARCH_COUNT)); do
            env_setup $t
            logfile=$LOGPATH/$p.log
            for i in 4 3 2 1; do
                test -f $logfile.$i || break
                mv $logfile.$i $logfile.$((i+1))
            done
            test -f $logfile && mv $logfile $logfile.1

            echo $base_path/build-$p.sh $t $clean > $logfile
            $base_path/build-$p.sh $t $clean 2>&1 | tee -a $logfile

            if [ ${PIPESTATUS[0]} -ne 0 ]; then
                echo failed
                exit 1
            fi
            
            if test $remove_shared; then
                echo removing shared library
                (cd $PREFIX/lib;rm -f *.la *.so *.dylib)
            fi
            ARCH_IDX=$((ARCH_IDX+1))
        done
    done

done

