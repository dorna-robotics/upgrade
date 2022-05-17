#!/bin/bash
upgrade="api dorna_lab"
dir=$(pwd)

# remove setup_1 service
python3 -c 'import service; service.cron_remove("dorna", "upgrade_setup_1")' 

for val in $upgrade; do
    cd $dir/$val
    sh setup_1.sh
done

# remove upgrade
rm -rf $dir

# reboot
#reboot