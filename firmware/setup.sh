#!/bin/bash 
# remove and reopen the folder
rm -rf ~/app
mkdir ~/app

# clone the repo
git clone https://github.com/dorna-robotics/firmware.git ~/app

# update config.txt and rc.local
python3 fw.py

# run the update
cd ~/app
sh upgrade