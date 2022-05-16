#!/bin/bash
upgrade="dorna_lab"
dir=$(pwd)

for val in $upgrade; do
    cd $dir/$val
    sh setup.sh
done

# remove upgrade
rm -rf $dir
cd ~

# reboot
#reboot