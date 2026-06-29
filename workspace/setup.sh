#!/bin/bash
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/workspace"
repo="https://github.com/dorna-robotics/workspace"

########################
#    clone the repo    #
########################
git clone $repo $dir
# navigate to directory
cd $dir
cd workspace
git restore .
git pull

# install package
pip3 install -e . --break-system-packages