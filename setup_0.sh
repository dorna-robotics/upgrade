#!/bin/bash
upgrade="server api dorna_lab"

dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# virtual env
cd $dir
source venv.sh

# make downloads directory
mkdir /home/dorna/Downloads

# install the requirements
pip3 install -r $dir/requirements.txt --upgrade

for val in $upgrade; do
    cd $dir/$val
    sh setup_0.sh
done

# go to home
cd ~

# remove the directory
#rm -rf $dir

# shutdown 
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@   Turn the controller OFF and ON to complete the update.   @"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"