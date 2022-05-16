#!/bin/bash
# variables
current_dir=$(pwd)
dir="/home/dorna/Downloads/dorna_lab"
dir_temp="/home/dorna/Downloads/dorna_lab_temp"

cron_add_name="dorna"
cron_add_path=$dir"/dorna_lab/application.py"
cron_add_command="python3"
cron_add_comment="dorna_lab"

cron_remove_name="dorna"
cron_remove_comment="dorna_lab_setup_2"


# remove and reopen the folder
rm -rf $dir
mkdir $dir

# navigate to temp directory
cd $dir_temp
pip3 install -r requirements.txt --upgrade

# sync
rsync -avh $dir_temp $dir --delete
rm -rf $dir_temp

# add service
cd $current_dir
python3 service.py -n $cron_add_name -c $cron_add_comment -p $cron_add_path -d cron_add_command

# remove setup_2 service
python3 service.py -n $cron_remove_name -c $cron_remove_comment

# run dorna_lab instance
$cron_add_path