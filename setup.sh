#!/bin/bash
upgrade="python api dorna_lab"
dir=$(pwd)

for val in $upgrade; do
    cd $dir/$val
    sh setup.sh
done

# remove upgrade
rm -rf $dir

# reboot
reboot