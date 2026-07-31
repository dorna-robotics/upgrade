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
    # Per-package install, in dependency order (driver-usb/tools-cli
    # PRE-depend on a CONFIGURED ueye-common, so they must come after
    # api+common are fully configured). Each package is touched ONLY
    # when its version/state mismatches: the IDS postinst uses bare
    # `ln -s` under set -e, so re-configuring an already-installed
    # package explodes with "File exists" — never reinstall what is
    # already correctly in place.
    ueye_install() {
        pkg="$1"; deb="$2"
        v=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || true)
        s=$(dpkg-query -W -f='${db:Status-Status}' "$pkg" 2>/dev/null || true)
        if [ "$v" != "$vendored" ] || [ "$s" != "installed" ]; then
            dpkg -i "$deb" || apt-get install -f -y
        fi
    }
    apt-get install -y libomp5 || true
    ueye_install ueye-api        "$dir"/ids/ueye-api_*.deb
    ueye_install ueye-common     "$dir"/ids/ueye-common_*.deb
    ueye_install ueye-driver-usb "$dir"/ids/ueye-driver-usb_*.deb
    ueye_install ueye-tools-cli  "$dir"/ids/ueye-tools-cli_*.deb
    # refresh the loader cache so libueye_api resolves for pyueye even
    # if a partial earlier attempt skipped the ldconfig trigger
    ldconfig || true
    systemctl enable ueyeusbdrc 2>/dev/null || true
fi

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages
