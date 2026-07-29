#!/bin/bash
set -e
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/workspace"
repo="https://github.com/dorna-robotics/workspace"
branch="main"

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

# navigate to package and install
cd workspace
pip3 install -e . --break-system-packages

###########################
#    device-bus broker    #
###########################
# make this workspace host the site's mosquitto broker (LAN listener on 1883).
# idempotent — only restarts mosquitto if /etc/mosquitto/conf.d/dorna-bus.conf changed.
command -v mosquitto >/dev/null 2>&1 || apt-get install -y mosquitto
python3 -m workspace.devices.provision_broker
