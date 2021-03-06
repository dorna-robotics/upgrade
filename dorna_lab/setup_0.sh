#!/bin/bash
# variables
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/dorna_lab"
repo="https://github.com/smhty/dorna_lab.git"
project="/home/dorna/Projects"
project_sub_dir="blockly script path_design python git"

# clone the repo
git clone $repo $dir
# navigate to directory
cd $dir
git restore .
git pull

# pip
#/home/dorna/Downloads/dorna_venv/bin/pip3 install -r requirements.txt
pip3 install -r requirements.txt

# create project directory
mkdir $project
for val in $project_sub_dir; do
    mkdir $project/$val
done

cd $current_dir
#/home/dorna/Downloads/dorna_venv/bin/python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_lab", "'$dir/dorna_lab/start.sh'", "sh")'
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_lab", "'$dir/dorna_lab/start.sh'", "sh")'
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "jupyter_notebook", "'$dir/dorna_lab/jupyter.sh'", "sh")'

# create the startup bash
if [ -f "$project/startup.sh" ]; then
    echo "startup file exists."
else 
    mv startup.sh $project
fi
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "dorna_startup", "'$project/startup.sh'", "sh")'
