#!/bin/sh

mv "build/Makefile" "build/Makefile~"
sed 's/preinstall\: all/preinstall\:/g' build/Makefile~ > build/Makefile

mv "build/src/CMakeFiles/yajl.dir/build.make" "build/src/CMakeFiles/yajl.dir/build.make~"
sed 's/\.dylib/\.so/g' build/src/CMakeFiles/yajl.dir/build.make~ > build/src/CMakeFiles/yajl.dir/build.make

FILES=`sed 's/^.*dylib CMakeFiles/CMakeFiles/' build/src/CMakeFiles/yajl.dir/link.txt`
echo "${CC} -nostdlib -lc -shared -Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -I${SYSROOT}/usr/include -o ../yajl-${YAJL_VERSION}/lib/libyajl.${YAJL_VERSION}.so $FILES" \
	> build/src/CMakeFiles/yajl.dir/link.txt

STATICLINKFILES="${AR} `sed 's/\/usr\/bin\/ar //' build/src/CMakeFiles/yajl_s.dir/link.txt | sed 's/^\/usr\/bin\/ranlib.*//'`"

echo "$STATICLINKFILES\n${RANLIB} ../yajl-${YAJL_VERSION}/lib/libyajl_s.a" \
	> build/src/CMakeFiles/yajl_s.dir/link.txt

mv "build/src/cmake_install.cmake" "build/src/cmake_install.cmake~"
sed 's/\.dylib/\.so/g' build/src/cmake_install.cmake~ > build/src/cmake_install.cmake

echo ".PHONY: all distro" > Makefile
echo "all: distro" >> Makefile
echo "\ndistro:" >> Makefile
echo "\t@cd build && make yajl yajl_s" >> Makefile
echo "\ninstall: all" >> Makefile
echo "\t@cd build && make install" >> Makefile

