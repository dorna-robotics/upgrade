#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/camera"
repo="https://github.com/dorna-robotics/camera"
branch="master"

########################
#    clone or pull     #
########################
sync_repo() {
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        if git fetch origin "$branch" \
            && git checkout -B "$branch" "origin/$branch" \
            && git reset --hard "origin/$branch"; then
            git clean -fd
            return 0
        fi
        cd /
    fi
    rm -rf "$dir"
    git clone -b "$branch" "$repo" "$dir"
    cd "$dir"
}
sync_repo

# install requirements (if present)
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt --break-system-packages
fi

# uEye XS support: pyueye is the python wrapper; the IDS Software Suite
# (libueye_api runtime) is a one-time manual install per unit from IDS.
# Without the runtime the camera type is simply unavailable — the server
# still starts and D405 cameras are unaffected.
pip3 install pyueye --break-system-packages

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages
