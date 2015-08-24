#!/bin/bash
set -e

# Package list
# A simplistic way of defining dependency by ording, Makefile would be better
packages="\
    json \
    libevent \
    cares \
    bzip2 \
    libgpg-error \
    libgcrypt \
    GnuPG \
    expat \
    openssl \
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
"
default="\
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
"
for p in ${packages[@]}; do
    declare PKG_${p//[-.]/_}=0
done

base_path=`dirname $0`

targets=
clean=
for arg in "$@" ; do
    case $arg in
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
            for p in $default; do
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

test $targets || targets=arm

. `dirname $0`/common.sh

for t in $targets; do

    env_setup $t
    mkdir -p $LOGPATH

    for p in $packages; do
        var=PKG_${p//[-.]/_}
        [ "${!var}" = "1" ] || continue
        $base_path/build-$p.sh $t $clean 2>&1 | tee $LOGPATH/$p.log
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo failed
            exit 1
        fi
    done

done

