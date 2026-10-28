#!/bin/bash
set -e

###############################
#    reboot watchdog timer    #
###############################
# systemd RebootWatchdogSec defaults to 10min; drop it to 30s so a hung reboot recovers quickly.
install -d /etc/systemd/system.conf.d
tee /etc/systemd/system.conf.d/10-reboot-watchdog.conf >/dev/null <<'CONF'
[Manager]
RebootWatchdogSec=30s
CONF
systemctl daemon-reexec

###########################
#    power: MAXN SUPER    #
###########################
# The Orin Nano Super's full clocks. Looked up by name — the mode ID
# differs between boards. nvpmodel keeps the mode across reboots.
mode=$(sed -n 's/^< POWER_MODEL ID=\([0-9]*\) NAME=MAXN_SUPER >.*/\1/p' /etc/nvpmodel.conf)
[ -n "$mode" ] && nvpmodel -m "$mode"

########################
#    system packages   #
########################
# The JetPack 7 ISO installs the bare L4T base: the NVIDIA stack comes
# from NVIDIA's apt repo (r39.2), only the parts this unit uses —
#   cuda-nvcc-13-2        nvcc + the CUDA runtime: librealsense's CUDA
#                         build; /usr/local/cuda
#   libcublas-dev-13-2    cuBLAS, cuSPARSE: librealsense links them;
#   libcusparse-dev-13-2  TensorRT loads cuBLAS
#   cuda-nvrtc-13-2       NVRTC: TensorRT compiles kernels with it
#   nvidia-tensorrt       TensorRT 10 — the vision models' engines
#   python3-libnvinfer    its python binding (there is no Jetson wheel)
#   nvidia-opencv         NVIDIA's OpenCV 4.8 (in /usr/lib, beside the
#   libopencv-python      ISO's Ubuntu 4.6 libs) and its cv2 — 4.8 has
#                         cv2.aruco / charuco in the main build
# The CUDA toolkit meta-package is NOT installed: it brings the
# profilers, the debugger and a dozen libraries nothing here uses.
# Then python's venv + headers, the build tools path_planning (vcpkg)
# and librealsense need (Ubuntu 24.04's cmake 3.28 reads their presets),
# libomp5 for the uEye runtime, and mosquitto for the device bus.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y cuda-nvcc-13-2 libcublas-dev-13-2 libcusparse-dev-13-2 cuda-nvrtc-13-2 \
    nvidia-tensorrt python3-libnvinfer nvidia-opencv libopencv-python
apt-get install -y python3-venv python3-dev build-essential cmake ninja-build pkg-config \
    git curl zip unzip tar autoconf autoconf-archive automake libtool intltool gettext \
    libssl-dev libusb-1.0-0-dev libudev-dev libomp5 mosquitto mosquitto-clients
systemctl enable --now mosquitto

#########################
#    the python venv    #
#########################
# Every python package the unit installs lives in ONE venv, $DORNA_VENV
# (setup.sh). Ubuntu 24.04's own python packages are apt's: pip cannot
# upgrade one of them (no RECORD), so pip never touches them — it
# installs into the venv, which sees apt's packages (TensorRT, cv2,
# numpy) through --system-site-packages and shadows them when a newer
# version is needed. The venv is first on every PATH — /etc/environment
# (ssh, logins, cron) and sudo's secure_path — so `sudo python3` and
# `sudo pip3` are the venv's, exactly as typed on the Pis. Created once;
# pip inside it is the venv's own and kept current.
[ -x "$DORNA_VENV/bin/python3" ] || /usr/bin/python3 -m venv --system-site-packages "$DORNA_VENV"
pip3 install -U pip

sed -i "s#^PATH=.*#PATH=\"$DORNA_VENV/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"#" /etc/environment
sudoers=$(mktemp)
echo "Defaults secure_path=\"$DORNA_VENV/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\"" > "$sudoers"
visudo -cqf "$sudoers"
install -m 440 "$sudoers" /etc/sudoers.d/020_dorna-venv
rm -f "$sudoers"

# proven here — the venv's python sees apt's NVIDIA stack — or the
# upgrade stops here
[ "$(command -v python3)" = "$DORNA_VENV/bin/python3" ]
python3 -c 'import tensorrt, cv2; print("tensorrt", tensorrt.__version__, "| cv2", cv2.__version__)'

###################################
#    the bench's services         #
###################################
# Everything a unit runs at boot is a systemd unit the upgrade owns —
# supervised (restarted on failure), every line in the journal
# (persistent, below), restarted by the component step that refreshes
# its code. Both servers run on this one computer. Units run as root,
# as on the Pis (sudo set HOME=/root; the units say so explicitly), on the
# venv's python with the venv first on PATH — a notebook's `!pip3` or a
# subprocess's `python3` is the venv's too (units do not read
# /etc/environment).
#   dorna-orchestrator   gui/server.py on :80
#   dorna-vision         python3 -m dorna_vision.server on :4001
#   dorna-jupyter        the bench's notebook on :8888
# All are ENABLED here and STARTED by the services step at the end of
# setup.sh, once every component is installed — and that step refuses to
# reboot a unit whose service does not answer.
# Site-specific environment, if ever needed, goes in
# /etc/default/<unit>, read when present.

# the orchestrator. WorkingDirectory / ExecStart follow the workspace
# repo's layout (…/workspace/workspace, gui/server.py) — if server.py
# moves, the unit must follow.
cat > /etc/systemd/system/dorna-orchestrator.service <<'UNIT'
[Unit]
Description=Dorna Workspace orchestrator (gui/server.py)
After=network-online.target mosquitto.service
Wants=network-online.target

[Service]
WorkingDirectory=/home/dorna/Downloads/workspace/workspace
Environment=HOME=/root PATH=/opt/dorna/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin PORT=80 PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-orchestrator
ExecStart=/opt/dorna/venv/bin/python3 -u gui/server.py
Restart=on-failure
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

# the vision server. :4001 — the orchestrator holds :80 on this computer,
# and 4001 is the vision port the workspace's j2 default names. The
# device bus is the local mosquitto (DEVICE_MQTT_HOST defaults to localhost).
cat > /etc/systemd/system/dorna-vision.service <<'UNIT'
[Unit]
Description=Dorna vision server (dorna_vision.server)
After=network-online.target mosquitto.service
Wants=network-online.target

[Service]
WorkingDirectory=/home/dorna/Downloads/vision
Environment=HOME=/root PATH=/opt/dorna/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-vision
ExecStart=/opt/dorna/venv/bin/python3 -u -m dorna_vision.server --host 0.0.0.0 --port 4001
Restart=on-failure
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

# Jupyter — the bench's notebook.
pip3 install notebook
cat > /etc/systemd/system/dorna-jupyter.service <<'UNIT'
[Unit]
Description=Jupyter notebook for the bench (port 8888)
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/home/dorna
Environment=HOME=/root PATH=/opt/dorna/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-jupyter
ExecStart=/opt/dorna/venv/bin/python3 -m jupyter notebook --ip 0.0.0.0 --no-browser --port=8888 --allow-root --notebook-dir=/home/dorna/ --NotebookApp.token= --NotebookApp.password=
Restart=on-failure
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

# persistent journald, so the logs survive a reboot fleet-wide (idempotent)
install -d /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal 2>/dev/null || true

systemctl daemon-reload
systemctl enable dorna-orchestrator dorna-vision dorna-jupyter
