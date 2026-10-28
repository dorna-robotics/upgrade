#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/librealsense"
repo="https://github.com/IntelRealSense/librealsense.git"
tag="v2.59.1"

# How it is built on the Jetson. RSUSB: the kernel-patch (V4L native)
# route does not support Orin. CUDA for the format conversions and align
# on the GPU. The python binding builds for, and installs into, the
# unit's venv (setup.sh's $DORNA_VENV) — systemd units included. No
# examples, no viewer, no telemetry (ENABLE_STATS), no update check.
flags="-DCMAKE_BUILD_TYPE=Release \
 -DFORCE_RSUSB_BACKEND=ON \
 -DBUILD_WITH_CUDA=ON -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc \
 -DBUILD_PYTHON_BINDINGS=ON -DPYTHON_EXECUTABLE=$DORNA_VENV/bin/python3 \
 -DPYTHON_INSTALL_DIR=$DORNA_VENV/lib/python3.12/site-packages/pyrealsense2 \
 -DBUILD_EXAMPLES=OFF -DBUILD_GRAPHICAL_EXAMPLES=OFF -DBUILD_GLSL_EXTENSIONS=OFF \
 -DBUILD_TOOLS=ON -DENABLE_STATS=OFF -DCHECK_FOR_UPDATES=OFF -DENABLE_AI_ASSISTANT=OFF"

# Orin's GPU (sm_87) under CUDA 13. librealsense sets the CUDA
# architectures itself (CMake/cuda_config.cmake — a -D cannot override
# it), and its table lists sm_87 only for CUDA < 13: built as is, every
# kernel fails on Orin with "no kernel image available". The fix is that
# one condition; the build stops if it no longer matches the source.
orin_old='if(CUDA_VERSION VERSION_GREATER_EQUAL "11.4" AND CUDA_VERSION VERSION_LESS "13.0")'
orin_new='if(CUDA_VERSION VERSION_GREATER_EQUAL "11.4")'

###########################
#    build when changed   #
###########################
# IDEMPOTENT VIA A STAMP: the tag + flags + sm_87 fix last installed. A build is
# 30-45 min on the Orin Nano, so it runs only when the pin changes or
# the install is missing — every other upgrade only proves the binding.
stamp="/var/lib/dorna/librealsense.installed"
want=$(printf '%s %s %s' "$tag" "$flags" "$orin_new" | sha256sum | cut -d' ' -f1)
have=$(cat "$stamp" 2>/dev/null || true)

if [ "$have" != "$want" ] || ! python3 -c 'import pyrealsense2' 2>/dev/null; then
    rm -rf "$dir"
    git clone --depth 1 -b "$tag" "$repo" "$dir"
    grep -qF "$orin_old" "$dir/CMake/cuda_config.cmake"
    sed -i "s|$orin_old|$orin_new|" "$dir/CMake/cuda_config.cmake"
    grep -qF "$orin_new" "$dir/CMake/cuda_config.cmake"
    mkdir -p "$dir/build"
    cd "$dir/build"
    cmake .. -G Ninja $flags
    ninja
    ninja install
    ldconfig
    mkdir -p "$(dirname "$stamp")"
    echo "$want" > "$stamp"
fi

# the USB permissions rule (RSUSB talks to the camera through libusb)
install -m 644 "$dir/config/99-realsense-libusb.rules" /etc/udev/rules.d/
udevadm control --reload-rules

# proven here, in a clean environment, or the upgrade stops here
cd /
env -u PYTHONPATH python3 -c 'import pyrealsense2 as rs; rs.stream; print("pyrealsense2", rs.__version__)'
