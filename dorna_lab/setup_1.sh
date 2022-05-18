#!/bin/bash
# variables
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/dorna_lab"
dir_temp="/home/dorna/Downloads/dorna_lab_temp"


# remove and reopen the folder
rm -rf $dir

# navigate to temp directory
cd $dir_temp
pip3 install -r requirements.txt --upgrade

# move
mv $dir_temp $dir
rm -rf $dir_temp


# add dorna_lab service
cd $current_dir
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_lab", "'$dir/dorna_lab/application.py'", "python3")' 


# run dorna_lab instance
python3 $dir/dorna_lab/application.py &