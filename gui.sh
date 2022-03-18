#!/bin/bash
# remove and reopen the folder
rm -rf ~/Downloads/dorna_lab
mkdir ~/Downloads/dorna_lab

# clone the repo
git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git ~/Downloads/dorna_lab

# create directory
mkdir ~/projects/blockly
mkdir ~/projects/script
mkdir ~/projects/path_design
mkdir ~/projects/python

# update service

# run the update
cd ~/Downloads/dorna_lab
python3 setup.py install --force