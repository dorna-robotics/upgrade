#!/bin/bash

###################
#    variables    #
###################
# sh folders
#upgrade="dorna_python dorna_lab example wizard server firmware"
upgrade="dorna_python dorna_lab example wizard"
# current dir
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

######################
#    check the OS    #
######################
# Get the version number from /etc/os-release
version=$(grep -oP '(?<=VERSION_ID=").*(?=")' /etc/os-release)

# Compare the version number
if dpkg --compare-versions "$version" lt 12; then
    echo "##################################################################################################################"
    echo "#    The Robot Operating System (OS) is outdated.                                                                #"
    echo "#    Before proceeding, please upgrade your robot controller OS to the latest version (version 12 or higher).    #"
    echo "##################################################################################################################"

    exit 1
fi

# install the requirements
pip3 install -r $current_dir/requirements.txt --break-system-packages

for val in $upgrade; do
    cd $current_dir/$val
    sh setup.sh $1
done

# remove the directory
rm -rf $current_dir

# sleep for 60 seconds
echo "Cleaning the buffer..."
sleep 30

# shutdown 
echo "###################################################"
echo "#    Setup process is now finished.               #"
echo "#    To finalize the update, follow these steps:  #"
echo "#      1. Wait for 30 seconds.                    #"
echo "#      2. Power cycle the controller.             #"
echo "###################################################"

# reboot
reboot