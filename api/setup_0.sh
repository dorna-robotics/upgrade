#!/bin/bash
# variables
dir="/home/dorna/Downloads/dorna_python"
repo="https://github.com/dorna-robotics/dorna2-python.git"

# remove and create the dir
#rm -rf $dir
#mkdir $dir

# get the latest version
git clone $repo $dir

# navigate to directory
cd $dir
git restore .
git pull

# install requirements
/home/dorna/Downloads/dorna_venv/bin/pip3 install -r requirements.txt --upgrade

# install the package
/home/dorna/Downloads/dorna_venv/bin/ setup.py install --force
