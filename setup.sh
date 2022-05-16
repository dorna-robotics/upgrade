#!/bin/bash
upgrade="dorna_lab"
dir=$(pwd)

for val in $upgrade; do
    cd $dir/$val
    sh setup.sh
done

# remove upgrade
cd..
rm -rf $dir

# reboot
#reboot