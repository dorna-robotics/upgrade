#!/bin/bash
# variables
current_dir=$(pwd)
dir="/home/dorna/Downloads/dorna_lab_temp"
repo="https://gitlab.com/smhty/dorna_lab.git"
branch="hamed"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python"

cron_add_name="dorna"
cron_add_path="sudo sh $current_dir/setup_2.sh"
cron_add_comment="dorna_lab_setup_2"

cron_remove_name="dorna"
cron_remove_comment="dorna_lab"


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

# update service
cd $current_dir
python3 service.py -n $cron_add_name -c $cron_add_comment -p $cron_add_path

# remove dorna lab service temporarily
python3 service.py -n $cron_remove_name -c $cron_remove_comment

