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
    # Repair a wedged earlier attempt first: a half-configured package
    # (postinst died on its own leftover symlinks) blocks everything
    # behind it. Clear the leftovers, then let dpkg finish configuring.
    for pkg in ueye-api ueye-common ueye-driver-usb ueye-tools-cli; do
        s=$(dpkg-query -W -f='${db:Status-Status}' "$pkg" 2>/dev/null || true)
        case "$s" in
            ""|installed|not-installed|config-files) ;;
            *)
                rm -f /opt/ids/ueye/lib/aarch64-linux-gnu/libueye_api.so.4.96 \
                      /usr/lib/aarch64-linux-gnu/libueye_api.so*
                dpkg --configure -a || true
                break
            ;;
        esac
    done
    ueye_install ueye-api        "$dir"/ids/ueye-api_*.deb
    ueye_install ueye-common     "$dir"/ids/ueye-common_*.deb
    ueye_install ueye-driver-usb "$dir"/ids/ueye-driver-usb_*.deb
    ueye_install ueye-tools-cli  "$dir"/ids/ueye-tools-cli_*.deb
    # refresh the loader cache so libueye_api resolves for pyueye even
    # if a partial earlier attempt skipped the ldconfig trigger
    ldconfig || true
    systemctl enable ueyeusbdrc 2>/dev/null || true
fi

# Hikrobot GigE support: the MVS runtime. The Python bindings ship in
# the camera repo (mvs/MvImport/), but they are ctypes wrappers — the
# runtime library itself must be installed. The deb is vendored in the
# camera repo, split in two because GitHub rejects files over 100 MB.
#
# IDEMPOTENT VIA A STAMP, NOT A VERSION STRING. The deb registers as
# package `mvs` with version "2022-10-24" — nothing to do with the
# "5.0.2" in its filename — so any filename-derived version check never
# matches and reinstalls 110 MB on every upgrade run. The stamp records
# the fingerprint of the vendored parts that were last installed, which
# is both version-scheme independent and correct when the vendored deb
# is replaced.
if ls "$dir"/mvs/MVS-*.deb.part-* >/dev/null 2>&1; then
    stamp="/var/lib/dorna/mvs.installed"
    want=$(sha256sum "$dir"/mvs/MVS-*.deb.part-* | awk '{print $1}' | sha256sum | cut -d' ' -f1)
    have=$(cat "$stamp" 2>/dev/null || true)
    state=$(dpkg-query -W -f='${db:Status-Status}' mvs 2>/dev/null || true)

    if [ "$have" != "$want" ] || [ "$state" != "installed" ]; then
        # Reassemble beside the parts, NOT in /tmp: /tmp is tmpfs on
        # some units and 110 MB of RAM mid-upgrade is a poor trade on a
        # 2 GB Pi.
        deb="$dir/mvs/.MVS-reassembled.deb"
        cat "$dir"/mvs/MVS-*.deb.part-* > "$deb"
        # VERIFY BEFORE INSTALLING. A truncated part — interrupted
        # clone, partial fetch — reassembles into a deb that is merely
        # wrong rather than obviously broken.
        expect=$(cut -d" " -f1 "$dir"/mvs/MVS-*.deb.sha256 2>/dev/null | head -1)
        got=$(sha256sum "$deb" | cut -d" " -f1)
        if [ -n "$expect" ] && [ "$expect" != "$got" ]; then
            echo "MVS: checksum mismatch, refusing to install" >&2
            echo "  want $expect" >&2
            echo "  got  $got" >&2
            rm -f "$deb"
        else
            dpkg -i "$deb" || apt-get install -f -y
            rm -f "$deb"
            mkdir -p "$(dirname "$stamp")"
            echo "$want" > "$stamp"
        fi
    fi

    # The installer exports MVCAM_COMMON_RUNENV from /etc/profile, which
    # ONLY login shells read — a systemd service gets nothing, and the
    # bindings then cannot locate libMvCameraControl.so. The driver
    # fills the variable in itself (hik_robot._posix_register_runtime_dirs);
    # this is for anything else on the box that expects the loader path.
    if [ -d /opt/MVS/lib/aarch64 ]; then
        echo "/opt/MVS/lib/aarch64" > /etc/ld.so.conf.d/mvs.conf
        ldconfig || true
    fi
fi

#################
#    install    #
#################
# editable install
pip3 install -e . --break-system-packages
