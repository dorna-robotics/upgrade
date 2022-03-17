#!/bin/bash
rm -rf ~/pkg/dorna_lab
mkdir ~/pkg/dorna_lab
git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git ~/pkg/dorna_lab
cd ~/pkg/dorna_lab
python3 setup.py install --force
