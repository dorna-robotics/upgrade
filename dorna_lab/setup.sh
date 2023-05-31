#!/bin/bash

# keep the logs in config.log

###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/dorna_lab"
config="/home/dorna/Downloads/dorna_lab/dorna_lab/config.log"
startup="/home/dorna/Downloads/dorna_lab/dorna_lab/startup.log"
repo="https://github.com/smhty/dorna_lab.git"
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
pip3 install -r requirements.txt

######################
#    adjust model    #
######################
# Define the key and value to add/update
key="model"
value=$1

# Check if the JSON file exists
if [ -f "$config" ]; then
    # Check if the key already exists in the JSON file
    if grep -q "\"$key\"" "$config"; then
        # Update the value of the existing key using sed
        sed -i "s/\"$key\": \".*\"/\"$key\": \"$value\"/" "$config"
    else
        # Add a new key-value pair to the JSON file using sed
        sed -i "s/{/{\"$key\": \"$value\", /" "$config"
    fi
else
    # Create a new JSON file with the key-value pair
    echo "{\"$key\": \"$value\"}" > "$config"
fi


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
