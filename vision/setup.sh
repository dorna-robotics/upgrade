#!/bin/bash
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/education"
repo="https://github.com/dorna-robotics/education"

########################
#    clone the repo    #
########################
git clone $repo $dir
# navigate to directory
cd $dir
git restore .
git pull

# opencv
# camera