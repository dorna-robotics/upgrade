#!/bin/bash
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/vision"
repo="https://github.com/dorna-robotics/dorna_vision"

########################
#    clone the repo    #
########################
git clone $repo $dir
# navigate to directory
cd $dir
git restore .
git pull

# install requirements
pip3 install -r requirements.txt --break-system-packages

# install package
pip3 install . --upgrade --force-reinstall --break-system-packages