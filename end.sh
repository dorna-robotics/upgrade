#!/bin/bash
dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# remove the directory
rm -rf $dir

# sleep for 60 seconds
echo "Cleaning the buffer..."
sleep 30

# shutdown 
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@    Setup process is completed.                  @"
echo "@    To complete the update:                      @"
echo "@      1- Wait for 30 seconds.                    @"
echo "@      2- Then turn the controller off and on.    @"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

# reboot
reboot