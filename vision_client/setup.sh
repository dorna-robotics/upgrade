#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/dorna_vision"
repo="https://github.com/dorna-robotics/dorna_vision"
branch="pro"

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

#################
#    install    #
#################
# install only the lightweight client subpackage (no torch/openvino/camera)
cd dorna_vision-client
pip3 install -e . --break-system-packages
