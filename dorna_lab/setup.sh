#!/bin/bash
# remove and reopen the folder
rm -rf /home/dorna/Downloads/dorna_lab
mkdir /home/dorna/Downloads/dorna_lab

# clone the repo
git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git /home/dorna/Downloads/dorna_lab

# create directory
mkdir /home/dorna/projects
mkdir /home/dorna/projects/blockly
mkdir /home/dorna/projects/script
mkdir /home/dorna/projects/path_design
mkdir /home/dorna/projects/python

# run the update
pip3 install -r requirements.txt --upgrade --force-reinstall

# update service
python3 service.py