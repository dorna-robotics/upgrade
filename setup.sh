#!/bin/bash

###################
#    variables    #
###################
# sh folders
upgrade="dorna_python dorna_lab example server firmware"
# current dir
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

######################
#    check the OS    #
######################
# Get the version number from /etc/os-release
version=$(grep -oP '(?<=VERSION_ID=").*(?=")' /etc/os-release)

# Compare the version number
if dpkg --compare-versions "$version" lt 11; then
    echo "##################################################################################################################"
    echo "#    The Robot Operating System (OS) is outdated.                                                                #"
    echo "#    Before proceeding, please upgrade your robot controller OS to the latest version (version 11 or higher).    #"
    echo "##################################################################################################################"

    exit 1
fi

######################################
#    add lines to /boot/config.txt   #
######################################
lines="dtoverlay=pi3-miniuart-bt enable_uart=1"

for line in $lines; do
  if grep -Fxq "$line" /boot/config.txt; then
    echo "Line '$line' already exists in /boot/config.txt"
  else
    echo "$line" | sudo tee -a /boot/config.txt
    echo "Line '$line' added to /boot/config.txt"
  fi
done


# install the requirements
pip3 install -r $current_dir/requirements.txt

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
echo "#    Setup process is completed.                  #"
echo "#    To complete the update:                      #"
echo "#      1- Wait for 30 seconds.                    #"
echo "#      2- Then power cycle the controller.        #"
echo "###################################################"

# reboot
reboot