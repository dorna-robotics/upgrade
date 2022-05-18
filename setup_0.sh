#!/bin/bash
upgrade="firmware api dorna_lab"

dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# install the requirements
pip3 install -r $dir/requirements.txt --upgrade

for val in $upgrade; do
    cd $dir/$val
    sh setup_0.sh
done

# add service for setp_1: cron_add(name, comment, path, command)
cd $dir
python3 -c 'import service; service.cron_add("dorna", "upgrade_setup_1", "'$dir/setup_1.sh'", "sh")' 

# shutdown 
echo "Turn the controller off and and on to complete the update"