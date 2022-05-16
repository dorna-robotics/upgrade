#!/bin/bash
upgrade="api dorna_lab firmware"
dir=$(pwd)

for val in $upgrade; do
    cd $dir/$val
    sh setup.sh
done

# remove upgrade
rm -rf $dir

# reboot
#reboot