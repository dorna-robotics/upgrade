#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/vision"
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

# install requirements (if present)
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt --break-system-packages
fi

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages

#######################################
#    (re)start the vision server      #
#######################################
# The code is in place: the legacy nohup'd server (if one still runs — it
# holds :80, the unit could not bind) goes, and the unit dorna-vision
# (os/setup.sh) starts, or restarts, so the unit serves THIS code now
# rather than the old code from memory until the reboot.
# Stop the unit first so the kill below never counts as a unit failure;
# pkill exits 1 when nothing matches — none of this may trip set -e.
systemctl stop dorna-vision || true
pkill -f 'dorna_vision.server' || true
systemctl start dorna-vision || true
