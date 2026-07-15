#!/bin/bash
set -e
###################
#    variables    #
###################
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/wizard"
repo="https://github.com/dorna-robotics/wizard.git"
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
# pip
pip3 install -r requirements.txt
