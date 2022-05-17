#!/bin/bash
upgrade=""
dir=$(pwd)

for val in $upgrade; do
    cd $dir/$val
    sh setup_1.sh
done

# remove setup_1 service
cd $dir
python3 -c 'import service; service.cron_remove("dorna", "upgrade_setup_1")' 

# remove upgrade
rm -rf $dir

# reboot
#reboot