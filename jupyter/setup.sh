#!/bin/bash
set -e
###################
#    variables    #
###################
# jupyter.sh must outlive the upgrade clone (the main setup removes it),
# so it is copied here before the cron points at it
dir="/home/dorna/Downloads/jupyter"

#################
#    install    #
#################
pip3 install notebook --break-system-packages

########################
#    run on startup    #
########################
mkdir -p "$dir"
cp jupyter.sh "$dir/jupyter.sh"
python3 -c 'import sys; sys.path.append(".."); import service; service.cron_add("dorna", "jupyter_notebook", "'$dir/jupyter.sh'", "sh")'
