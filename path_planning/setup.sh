#!/bin/bash
###################
#    variables    #
###################
# Load environment variables

VCPKG_ROOT="/home/dorna/Downloads/vcpkg"
export VCPKG_ROOT
PATH="$VCPKG_ROOT:$PATH"
export PATH

echo "VCPKG_ROOT=$VCPKG_ROOT"

current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/path_planning"
repo="https://github.com/dorna-robotics/path_planning"

########################
#    pull the repo    #
########################
# navigate to directory
cd $dir
git restore .
git pull

# clear old build
# rm -rf build/

# make and install
cmake --preset rpi-arm64
cmake --build --preset build-rpi64 -j
cmake --install build/rpi-arm64
