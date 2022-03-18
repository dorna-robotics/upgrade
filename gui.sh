#!/bin/bash
# remove and reopen the folder
rm -rf ~/pkg/dorna_lab
mkdir ~/pkg/dorna_lab

# clone the repo
git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git ~/pkg/dorna_lab

# create directory
mkdir ~/projects/blockly
mkdir ~/projects/script
mkdir ~/projects/path_design
mkdir ~/projects/python

# update rc.local
cd ~/Downloads/upgrade
python3 gui.py

# run the update
cd ~/pkg/dorna_lab
python3 setup.py install --force