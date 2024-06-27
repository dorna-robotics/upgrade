#!/bin/bash
###################
#    variables    #
###################
dir="/home/dorna/Downloads/dorna_python"
repo="https://github.com/dorna-robotics/dorna2-python.git"

########################
#    clone the repo    #
########################
git clone $repo $dir

# navigate to directory
cd $dir
git restore .
git pull

# install requirements
pip3 install -r requirements.txt

#################
#    install    #
#################
# install package
cd ..
pip3 install --upgrade --force-reinstall dorna_python/
#pip3 install . --upgrade --force-reinstall --break-system-packages
