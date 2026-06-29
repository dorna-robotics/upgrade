#!/bin/bash
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/workspace"
repo="https://github.com/dorna-robotics/workspace"

########################
#    clone or pull     #
########################
if [ -d "$dir/.git" ]; then
    cd $dir
    git restore .
    git pull
else
    rm -rf $dir
    git clone $repo $dir
    cd $dir
fi

# navigate to package and install
cd workspace
pip3 install -e . --break-system-packages