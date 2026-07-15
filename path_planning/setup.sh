#!/bin/bash
set -e
###################
#    variables    #
###################
# Load environment variables

VCPKG_ROOT="/home/dorna/Downloads/vcpkg"
export VCPKG_ROOT
PATH="$VCPKG_ROOT:$PATH"
export PATH

echo "VCPKG_ROOT=$VCPKG_ROOT"

current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
dir="/home/dorna/Downloads/path_planning"
repo="https://github.com/dorna-robotics/path_planning"
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

# clear old build
# rm -rf build/

# make and install
cmake --preset rpi-arm64
cmake --build --preset build-rpi64 -j
cmake --install build/rpi-arm64
