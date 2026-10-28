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

# vcpkg itself, pinned: a release tag, bootstrapped with telemetry off.
# Re-pinned (fresh clone) only when the tag below changes.
vcpkg_tag="2026.10.16"
if [ "$(git -C "$VCPKG_ROOT" describe --tags --exact-match 2>/dev/null)" != "$vcpkg_tag" ]; then
    rm -rf "$VCPKG_ROOT"
    git clone --depth 1 -b "$vcpkg_tag" https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
    "$VCPKG_ROOT"/bootstrap-vcpkg.sh -disableMetrics
fi

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

# make and install — the python module for, and into, the unit's venv
cmake --preset rpi-arm64 -DPython3_EXECUTABLE="$DORNA_VENV/bin/python3"
cmake --build --preset build-rpi64 -j
cmake --install build/rpi-arm64

# the python side: planner.py / urdf.py import fcl and urchin
pip3 install python-fcl urchin
