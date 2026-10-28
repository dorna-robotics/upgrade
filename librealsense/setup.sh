#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/librealsense"
repo="https://github.com/IntelRealSense/librealsense.git"
tag="v2.59.1"

# How it is built on the Jetson. RSUSB: the kernel-patch (V4L native)
# route does not support Orin on JetPack 6. CUDA for the format
# conversions and align on the GPU (Orin = sm_87). The python binding
# installs into the system site dir, so pyrealsense2 imports from any
# environment (systemd units included). No examples, no viewer, no
# telemetry (ENABLE_STATS), no update check.
flags="-DCMAKE_BUILD_TYPE=Release \
 -DFORCE_RSUSB_BACKEND=ON \
 -DBUILD_WITH_CUDA=ON -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc -DCMAKE_CUDA_ARCHITECTURES=87 \
 -DBUILD_PYTHON_BINDINGS=ON -DPYTHON_EXECUTABLE=/usr/bin/python3 \
 -DPYTHON_INSTALL_DIR=/usr/local/lib/python3.10/dist-packages/pyrealsense2 \
 -DBUILD_EXAMPLES=OFF -DBUILD_GRAPHICAL_EXAMPLES=OFF -DBUILD_GLSL_EXTENSIONS=OFF \
 -DBUILD_TOOLS=ON -DENABLE_STATS=OFF -DCHECK_FOR_UPDATES=OFF -DENABLE_AI_ASSISTANT=OFF"

###########################
#    build when changed   #
###########################
# IDEMPOTENT VIA A STAMP: the tag + flags last installed. A build is
# 30-45 min on the Orin Nano, so it runs only when the pin changes or
# the install is missing — every other upgrade only proves the binding.
stamp="/var/lib/dorna/librealsense.installed"
want=$(printf '%s %s' "$tag" "$flags" | sha256sum | cut -d' ' -f1)
have=$(cat "$stamp" 2>/dev/null || true)

if [ "$have" != "$want" ] || ! python3 -c 'import pyrealsense2' 2>/dev/null; then
    rm -rf "$dir"
    git clone --depth 1 -b "$tag" "$repo" "$dir"
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
