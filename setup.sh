#!/bin/bash 
# api
cd /home/dorna/Downloads/upgrade/api
sh setup.sh

# firmware
cd /home/dorna/Downloads/upgrade/dorna_lab
sh setup.sh

# firmware
cd /home/dorna/Downloads/upgrade/firmware
sh setup.sh

# reboot
reboot