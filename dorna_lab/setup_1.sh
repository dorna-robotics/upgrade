#!/bin/bash
# variables
current_dir=$(pwd)
dir="/home/dorna/Downloads/dorna_lab"
dir_temp="/home/dorna/Downloads/dorna_lab_temp"


# remove and reopen the folder
rm -rf $dir
mkdir $dir

# navigate to temp directory
cd $dir_temp
pip3 install -r requirements.txt --upgrade

# sync
rsync -avh $dir_temp/ $dir/ --delete
rm -rf $dir_temp


# add service
cd $current_dir
python3 -c 'import ..service; service.cron_add("dorna", "dorna_lab", "'$dir/dorna_lab/application.py'", "python3")' 


# remove dorna lab service temporarily
python3 -c 'import ..service; service.cron_remove("dorna", "dorna_lab_setup_1")' 


# run dorna_lab instance
python3 $dir/dorna_lab/application.py