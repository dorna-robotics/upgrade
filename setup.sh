#!/bin/bash 
for val in "api dorna_lab firmware"; do
    cd $(pwd)/$val
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