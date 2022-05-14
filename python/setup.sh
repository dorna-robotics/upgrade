#!/bin/bash 
# variables
version="3.10.4"
version_short="3.10"
repo="https://www.python.org/ftp/python/"$version"/Python-"$version".tgz"
dir="/home/dorna/Downloads/python"
repo="https://github.com/smhty/firmware.git"

# remove and reopen the folder
rm -rf $dir
mkdir $dir

# check the version
if hash python$version_short
then
    exit
fi


# install
wget $repo -P $dir
cd $dir
tar -zxvf Python-$version.tgz
cd Python-$version
./configure --enable-optimizations
make altinstall

# remove all the files
cd $dir
cd ..
rm -rf $dir

# add python to python3
cd /usr/bin
rm python3
ln -s /usr/local/bin/python$version_short python3


