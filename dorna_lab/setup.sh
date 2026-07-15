#!/bin/bash
set -e

# keep the logs in config.log

###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/dorna_lab"
config="/home/dorna/Downloads/dorna_lab/dorna_lab/user_data/config.log"
startup="/home/dorna/Downloads/dorna_lab/dorna_lab/startup.log"
repo="https://github.com/smhty/dorna_lab.git"
branch="dorna_ta"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python git"


########################
#    clone or pull     #
########################
sync_repo() {
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        if git fetch origin "$branch" \
            && git checkout -B "$branch" "origin/$branch" \
            && git reset --hard "origin/$branch"; then
            git clean -fd
            return 0
        fi
        cd /
    fi
    rm -rf "$dir"
    git clone -b "$branch" "$repo" "$dir"
    cd "$dir"
}
sync_repo
# pip
pip3 install -r requirements.txt

############################
#    adjust config file    #
############################
# Define the key and value to add/update
value=$1
python3 $dir/dorna_lab/user_data/config_init.py $value $config


##################################
#    create project directory    #
##################################
mkdir -p "$project"
for val in $project_sub_dir; do
    mkdir -p "$project/$val"
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
