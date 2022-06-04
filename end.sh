#!/bin/bash
dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# remove the directory
rm -rf $dir

# shutdown 
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@   Turn the controller OFF and ON to complete the update.   @"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"