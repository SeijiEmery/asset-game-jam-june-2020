#!/usr/bin/env bash
echo "extracting art assets..."
cd assets && ./extract.sh && cd ..
echo "building + installing nuklear lib(s)"
./external/install_nuklear.sh
