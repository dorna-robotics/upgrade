#!/bin/bash
# set error
set -e

# create virtual env and activate
python3 -m venv /home/dorna/Downloads/dorna_venv

# sh folders
upgrade="api dorna_lab server"

dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# install the requirements
/home/dorna/Downloads/dorna_venv/bin/pip3 install --upgrade --force-reinstall -r $dir/requirements.txt

for val in $upgrade; do
    cd $dir/$val
    sh setup_0.sh
done