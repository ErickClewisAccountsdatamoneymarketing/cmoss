#!/bin/sh

# Remove test and doc targets as that fails for device builds
mv "CMakeLists.txt" "CMakeLists.txt~1"
sed 's/ADD_SUBDIRECTORY(test)//' CMakeLists.txt~1 > CMakeLists.txt~2
sed 's/ADD_SUBDIRECTORY(reformatter)//' CMakeLists.txt~2 > CMakeLists.txt~3
sed 's/ADD_SUBDIRECTORY(verify)//' CMakeLists.txt~3 > CMakeLists.txt

