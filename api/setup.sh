#!/bin/bash
# update directory
rm -rf ~/Downloads/dorna_python
mkdir ~/Downloads/dorna_python

# get the latest version
git clone --branch asyncio https://github.com/dorna-robotics/dorna2-python.git ~/Downloads/dorna_python

# navigate to directory
cd ~/Downloads/dorna_python

# install
python3 setup.py install --force