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

# uEye XS support: pyueye (python wrapper) + the IDS uEye runtime.
# The runtime debs are vendored in the camera repo (ids/ — login-gated
# upstream); install is idempotent: skipped while the installed
# ueye-api version matches the vendored one. Harmless on units with no
# uEye plugged in — the daemon idles, D405 operation is unaffected.
pip3 install pyueye --break-system-packages

if ls "$dir"/ids/ueye-api_*.deb >/dev/null 2>&1; then
    vendored=$(basename "$dir"/ids/ueye-api_*.deb | sed 's/^ueye-api_\(.*\)_arm64\.deb$/\1/')
    installed=$(dpkg-query -W -f='${Version}' ueye-api 2>/dev/null || true)
    if [ "$installed" != "$vendored" ]; then
        apt-get install -y libomp5 || true
        dpkg -i "$dir"/ids/ueye-api_*.deb "$dir"/ids/ueye-common_*.deb \
                "$dir"/ids/ueye-driver-usb_*.deb "$dir"/ids/ueye-tools-cli_*.deb \
            || apt-get install -f -y
        systemctl enable ueyeusbdrc 2>/dev/null || true
    fi
fi

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages
