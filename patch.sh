#!/bin/bash

# usage: patch.sh <name> [-v <version>] [-t <type>]
#   use 'version' for version specific patches
#   use 'type' to distiguish different type of patches. 
#       e.g. patches to apply before or after configure

name=$1
shift

version=
type=
while getopts :v:t: opt; do
    case $opt in
    v) 
        version=$OPTARG;;
    t) 
        type=$OPTARG;;
    *) 
        echo "unknown option : -$OPTARG"
        exit 1;
    esac
done

if test -z $name; then
    echo "no name specified" >&2
    exit 1
fi

patchdir=${TOPDIR}/patches/$name

if [ "`uname -s`" = Darwin ]; then
    os=mac
else
    os=linux
fi

apply_patch()
{
    local dir=$1
    test -d $dir || return 0
    local patches=`find $dir -maxdepth 1 -name "*.patch" | sort 2> /dev/null`
    if test "$patches" ; then
        for p in $patches; do
            echo "Applying `basename $p`"
            if ! patch -p1 < $p; then
                echo "failed to apply $p">&2
                exit 1
            fi
        done
    fi
    local patches=`find $dir -maxdepth 1 -name "*.sh" | sort 2> /dev/null`
    if test "$patches" ; then
        for p in $patches; do
            echo "Applying `basename $p`"
            if ! $p; then
                echo "failed to apply $p">&2
                exit 1
            fi
        done
    fi
}

if test ! -f .$name-$type-patched; then
    apply_patch $patchdir/$type
    apply_patch $patchdir/$os/$type
    test $version && apply_patch $patchdir/$version/$type && \
        apply_patch $patchdir/$os/$version/$type
    touch .$name-$type-patched
fi
