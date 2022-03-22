#!/bin/bash 
# remove and reopen the folder
rm -rf /home/dorna/app
mkdir /home/dorna/app

# clone the repo
git clone https://github.com/dorna-robotics/firmware.git /home/dorna/app

# update config.txt and rc.local
python3 fw.py

# run the update
cd /home/dorna/app
sh upgrade