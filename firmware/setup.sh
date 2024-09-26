#!/bin/bash 
# variables
dir_temp="/home/dorna/Downloads/firmware_temp"
repo="https://github.com/smhty/firmware.git"

# remove and reopen the folder
rm -rf $dir_temp
mkdir $dir_temp

# clone the repo
git clone $repo $dir_temp

# run the update
cd $dir_temp/$1

# installation
pip3 install -r requirements.txt --break-system-packages
python3 ENC.py
python3 Unlock_Flash.py
python3 Firmware_Upgrade.py
python3 Lock_Flash.py

# remove tmp folder
rm -rf $dir_temp