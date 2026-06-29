#!/bin/bash
###################
#    variables    #
###################
dir="/home/dorna/Downloads/dorna_devices"
repo="https://github.com/dorna-robotics/dorna_devices.git"

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

# install requirements (if present)
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt --break-system-packages
fi

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages
