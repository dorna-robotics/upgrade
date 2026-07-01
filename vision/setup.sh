#!/bin/bash
###################
#    variables    #
###################
dir="/home/dorna/Downloads/vision"
repo="https://github.com/dorna-robotics/dorna_vision"
branch="pro"

########################
#    clone or pull     #
########################
if [ -d "$dir/.git" ]; then
    cd $dir
    git restore .
    git fetch origin
    git checkout $branch
    git pull
else
    rm -rf $dir
    git clone -b $branch $repo $dir
    cd $dir
fi

# install requirements (if present)
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt --break-system-packages
fi

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages
