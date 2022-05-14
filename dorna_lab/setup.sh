#!/bin/bash
# variables
current_dir=$(pwd)
dir="/home/dorna/Downloads/dorna_lab"
repo="https://gitlab.com/smhty/dorna_lab.git"
branch="hamed"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python"

cron_name="dorna"
cron_path="$dir/dorna_lab/application.py"
cron_comment="dorna_lab"

# remove and reopen the folder
rm -rf $dir
mkdir $dir

# clone the repo
git clone --branch $branch $repo $dir

# create project directory
mkdir $project
for val in $project_sub_dir; do
    mkdir $project/$val
done

# navigate to directory
cd $dir
python3 -m pip install -r requirements.txt --upgrade --force-reinstall

# update service
cd $current_dir
python3 service.py -n $cron_name -p $cron_path -c $cron_comment
