#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/dorna_python"
repo="https://github.com/dorna-robotics/dorna2-python.git"
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

# install requirements
pip3 install -r requirements.txt --break-system-packages

#################
#    install    #
#################
# install package
pip3 install . --upgrade --force-reinstall --break-system-packages
