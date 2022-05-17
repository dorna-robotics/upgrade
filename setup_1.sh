#!/bin/bash
upgrade="dorna_lab"
dir=$(pwd)


for val in $upgrade; do
    cd $dir/$val
    sh setup_1.sh
done

# remove upgrade
#rm -rf $dir

# reboot
#reboot