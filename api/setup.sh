#!/bin/bash
# update directory
rm -rf /home/dorna/Downloads/dorna_python
mkdir /home/dorna/Downloads/dorna_python

# get the latest version
git clone --branch asyncio https://github.com/dorna-robotics/dorna2-python.git /home/dorna/Downloads/dorna_python

# navigate to directory
cd /home/dorna/Downloads/dorna_python

# install
python3 setup.py install --force