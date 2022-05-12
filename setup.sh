#!/bin/bash
upgrade="api dorna_lab"
root_path = $(pwd)
for val in $upgrade; do
    cd $root_path/$val
    sh setup.sh
done

# reboot
reboot

# api
#cd $(pwd)/api
#sh setup.sh

# gui
#cd $(pwd)/dorna_lab
#sh setup.sh

# firmware
#cd $(pwd)/firmware
#sh setup.sh

# reboot
#reboot