#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/dorna_vision"
repo="https://github.com/dorna-robotics/dorna_vision"
branch="pro"
label="Vision client"            # the name the upgrade's record shows (lib/record.sh)

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

#####################
#    the record     #
#####################
# this part, as installed, in the upgrade's record (lib/record.sh)
[ -z "${DORNA_UPGRADE_HOME:-}" ] || . "$DORNA_UPGRADE_HOME/lib/record.sh"
