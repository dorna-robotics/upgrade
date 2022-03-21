#!/bin/bash
# remove and reopen the folder
rm -rf ~/Downloads/dorna_lab
mkdir ~/Downloads/dorna_lab

# clone the repo
git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git ~/Downloads/dorna_lab

# create directory
mkdir ~/projects
mkdir ~/projects/blockly
mkdir ~/projects/script
mkdir ~/projects/path_design
mkdir ~/projects/python

# run the update
pip3 install -r requirements.txt --upgrade --force-reinstall

# update service
python3 service.py