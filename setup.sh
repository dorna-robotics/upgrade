#!/bin/bash
upgrade="dorna_lab"
dir=$(pwd)

# install the requirements
pip3 install -r $dir/requirements.txt --upgrade

for val in $upgrade; do
    cd $dir/$val
    sh setup.sh
done

# remove upgrade
#rm -rf $dir

# reboot
#reboot