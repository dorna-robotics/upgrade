#!/bin/bash

# keep the logs in config.log

###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/dorna_lab"
config="/home/dorna/Downloads/dorna_lab/dorna_lab/user_data/config.log"
startup="/home/dorna/Downloads/dorna_lab/dorna_lab/startup.log"
repo="-b dorna_ta https://github.com/smhty/dorna_lab.git"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python git"


########################
#    clone the repo    #
########################
git clone $repo $dir
# navigate to directory
cd $dir
git restore .
git pull
# pip
pip3 install -r requirements.txt --break-system-packages

############################
#    adjust config file    #
############################
# Define the key and value to add/update
value=$1
python3 $dir/dorna_lab/user_data/config_init.py $value $config


##################################
#    create project directory    #
##################################
mkdir $project
for val in $project_sub_dir; do
    mkdir $project/$val
done

########################
#    run on startup    #
########################
cd $current_dir
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_lab", "'$dir/dorna_lab/start.sh'", "sh")'
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "jupyter_notebook", "'$dir/dorna_lab/jupyter.sh'", "sh")'

################################
#    create the startup bash   #
################################
if [ -f "$startup" ]; then
    echo "startup file exists."
else 
    mv startup.sh $startup
fi

if [ -f "$project/startup.sh" ]; then
    echo "startup file exists."
else 
    mv startup.sh $project
fi
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_startup", "'$project/startup.sh'", "sh")'
