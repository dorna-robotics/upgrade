#!/bin/bash
# take a.out
# two configs axes.cfg and offsets.cfg
# repo structure, dorna2 and dorna 2s inside each there is server.tar.gz

###################
#    variables    #
###################
dir="/home/dorna/app"
repo="https://github.com/smhty/server.git"

########################
#    clone the repo    #
########################

# make dir if it does not exists and create a.out
mkdir -p $dir
rm -rf $dir/a.out

# clone the repo
mkdir -p $dir/tmp
git clone $repo $dir/tmp

# add a.out to rc.local
python3 server.py

#############################
#    add the right files    #
#############################
# go to the hardware folder
cd $dir/tmp/$1

# get a.out and move it back 
tar -xvf server.tar.gz
mv a.out $dir

# remove temporary folder
rm -rf $dir/tmp