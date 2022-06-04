#!/bin/bash 
# variables
dir="/home/dorna/app"
repo="https://github.com/smhty/server.git"

# remove and reopen the folder
#rm -rf $dir
#mkdir $dir

# clone the repo
git clone $repo $dir


# update config.txt and rc.local
/home/dorna/Downloads/dorna_venv/bin/python3 server.py

# navigate to directory
cd $dir
git restore .
git pull

# run the upgrade
sh upgrade.sh
