#!/usr/bin/env bash
git submodule init && git submodule update
mkdir -p external/bindbc-nuklear/build && cd external/bindbc-nuklear/build
rm -rf ../include/* ../lib/*
cmake ../c &&
make install &&
echo "installing nuklear.h to /usr/local/include" &&
cp ../include/nuklear.h /usr/local/include &&
cp ../lib/libnuklear* /usr/local/lib &&
for file in ../lib/libnuklear*
do
echo "installing $file to /usr/local/lib"
done &&
echo "installed versions: " && ls -l /usr/local/include/nuklear* /usr/local/lib/libnuklear*
