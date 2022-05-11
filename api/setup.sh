#!/bin/bash
# variables
dir="/home/dorna/Downloads/dorna_python"
repo="https://github.com/dorna-robotics/dorna2-python.git"
branch="asyncio"

# remove and create the dir
rm -rf $dir
mkdir $dir

# get the latest version
git clone --branch $branch $repo $dir

# navigate to directory
cd $dir

# install
python3 setup.py install --force