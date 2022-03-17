#!/bin/bash
rm -rf ~/pkg/dorna_python
mkdir ~/pkg/dorna_python
git clone --branch asyncio https://github.com/dorna-robotics/dorna2-python.git ~/pkg/dorna_python
cd ~/pkg/dorna_python
python3 setup.py install --force