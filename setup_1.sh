#!/bin/bash
upgrade="dorna_lab"

dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

for val in $upgrade; do
    cd $dir/$val
    sh setup_1.sh
done

cd $dir
# remove setup_1 service
python3 -c 'import service; service.cron_remove("dorna", "upgrade_setup_1")' 

# remove upgrade
rm -rf $dir