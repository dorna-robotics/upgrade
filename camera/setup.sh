#!/bin/bash
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/camera"
repo="https://github.com/dorna-robotics/camera"

########################
#    clone the repo    #
########################
git clone $repo $dir
# navigate to directory
cd $dir
git restore .
git pull

# install package
pip3 install . --upgrade --force-reinstall --break-system-packages
