#!/bin/bash
# remove and reopen the folder
rm -rf /home/dorna/Downloads/dorna_lab
mkdir /home/dorna/Downloads/dorna_lab

# clone the repo
git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git /home/dorna/Downloads/dorna_lab

# create directory
mkdir /home/dorna/Projects
mkdir /home/dorna/Projects/blockly
mkdir /home/dorna/Projects/script
mkdir /home/dorna/Projects/path_design
mkdir /home/dorna/Projects/python

# run the update
pip3 install -r requirements.txt --upgrade --force-reinstall

# update service
python3 service.py