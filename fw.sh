#!/bin/bash
rm -rf ~/app
mkdir ~/app  
git clone https://github.com/dorna-robotics/firmware.git ~/app
cd ~/app
sh upgrade