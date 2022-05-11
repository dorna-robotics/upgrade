#!/bin/bash 
# variables
dir="/home/dorna/app"
repo="https://github.com/smhty/firmware.git"

# remove and reopen the folder
rm -rf $dir
mkdir $dir

# clone the repo
git clone $repo $dir

# update config.txt and rc.local
python3 fw.py

# run the update
cd $dir
sh upgrade