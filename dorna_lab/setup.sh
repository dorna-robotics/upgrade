#!/bin/bash
# variables
current_dir=$(pwd)
dir="/home/dorna/Downloads/dorna_lab"
dir_temp="/home/dorna/Downloads/dorna_lab_temp"
repo="https://gitlab.com/smhty/dorna_lab.git"
branch="hamed"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python"

cron_name="dorna"
cron_path="$dir/dorna_lab/application.py"
cron_comment="dorna_lab"

# remove and reopen the folder
#rm -rf $dir
#mkdir $dir

# clone the repo
#git clone --branch $branch $repo $dir
git clone --branch $branch $repo $dir_temp

# create project directory
mkdir $project
for val in $project_sub_dir; do
    mkdir $project/$val
done

# navigate to directory
#cd $dir
cd $dir_temp
#pip3 install -r requirements.txt --upgrade --force-reinstall
pip3 install -r requirements.txt --upgrade

# update service
cd $current_dir
python3 service.py -n $cron_name -p $cron_path -c $cron_comment


#Make a backup in "current.old"
#mv $dir $dir.old

#copy from backup
#cp -R $dir_temp $dir

# remove the old and tmp directory
#rm -rf $dir_temp
#rm -rf $dir.old
echo "ALIALI123"