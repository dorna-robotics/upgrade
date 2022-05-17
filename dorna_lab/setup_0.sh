#!/bin/bash
# variables
current_dir=$(pwd)
dir="/home/dorna/Downloads/dorna_lab_temp"
repo="https://gitlab.com/smhty/dorna_lab.git"
branch="hamed"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python"


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
python3 -c 'import ..service; service.cron_add("dorna", "dorna_lab_setup_1", "'$current_dir/setup_1.sh'", "sh")' 


# remove dorna lab service temporarily
python3 -c 'import ..service; service.cron_remove("dorna", "dorna_lab")' 

