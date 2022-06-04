#!/bin/bash
# variables
dir="/home/dorna/Downloads/dorna_python"
repo="https://github.com/dorna-robotics/dorna2-python.git"

# remove and create the dir
rm -rf $dir
mkdir $dir

# get the latest version
git clone $repo $dir

# navigate to directory
cd $dir

# install requirements
pip3 install -r requirements.txt --upgrade

# install package
cd ..
pip3 install --upgrade --force-reinstall dorna_python/