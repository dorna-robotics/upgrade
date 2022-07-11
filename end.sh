#!/bin/bash
dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# remove the directory
rm -rf $dir

# sleep for 60 seconds
echo "Cleaning the buffer..."
sleep 30

# shutdown 
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@    Setup is completed.   @"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

# reboot
reboot