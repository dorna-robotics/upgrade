#!/bin/bash
# variables
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/dorna_lab"
repo="https://github.com/smhty/dorna_lab.git"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python"

# remove and reopen the folder
rm -rf $dir
mkdir $dir

# clone the repo
git clone $repo $dir

cd $dir
pip3 install -r requirements.txt --upgrade

# create project directory
mkdir $project
for val in $project_sub_dir; do
    mkdir $project/$val
done

cd $current_dir
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_lab", "'$dir/dorna_lab/start.sh'", "sh")' 

