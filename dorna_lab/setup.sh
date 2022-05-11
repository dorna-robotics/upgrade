#!/bin/bash
# variables
dir="/home/dorna/Downloads/dorna_lab"
repo="https://gitlab.com/smhty/dorna_lab.git"
branch="hamed"
project="/home/dorna/Projects"

cron_name="dorna"
cron_path="$dir/dorna_lab/application.py"
cron_comment="dorna_lab"

# remove and reopen the folder
rm -rf $dir
mkdir $dir

# clone the repo
git clone --branch $branch $repo $dir


# navigate to directory
cd $dir
pip3 install -r requirements.txt --upgrade --force-reinstall

# create project directory
mkdir $project
for val in "blockly script path_design python"; do
    mkdir $project/$val
done

# update service
python3 service.py $cron_name $cron_path $cron_comment