#!/bin/bash
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/path_planning"
repo="https://github.com/dorna-robotics/path_planning"

########################
#    clone the repo    #
########################
git clone $repo $dir
# navigate to directory
cd $dir
git restore .
git pull

#clear old build
rm -rf build/

#make and install
cmake --preset rpi-arm64
cmake --build --preset build-rpi64 -j
sudo cmake --install build/rpi-arm64
