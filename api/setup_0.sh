#!/bin/bash
# variables
dir="/home/dorna/Downloads/dorna_python"
repo="https://github.com/dorna-robotics/dorna2-python.git"

# get the latest version
git clone $repo $dir

# navigate to directory
cd $dir
git restore .
git pull

# install requirements
#/home/dorna/Downloads/dorna_venv/bin/pip3 install -r requirements.txt
pip3 install -r requirements.txt

# install package
cd ..
#/home/dorna/Downloads/dorna_venv/bin/pip3 install --upgrade --force-reinstall dorna_python/
pip3 install --upgrade --force-reinstall dorna_python/