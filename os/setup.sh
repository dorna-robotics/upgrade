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
# JetPack ships no pip and an Ubuntu 22.04 toolchain: pip, the build
# tools path_planning (vcpkg) and librealsense need, libomp5 for the
# uEye runtime, and mosquitto for the device bus.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y python3-pip python3-dev build-essential ninja-build pkg-config \
    git curl zip unzip tar autoconf autoconf-archive automake libtool intltool gettext \
    libssl-dev libusb-1.0-0-dev libudev-dev libomp5 mosquitto mosquitto-clients
systemctl enable --now mosquitto

# Ubuntu's pip (22.0) builds in isolation without PEP 660, so its
# setuptools cannot do editable installs; path_planning's presets need
# CMake >= 3.24 (Ubuntu has 3.22). pip's cmake lands in /usr/local/bin,
# ahead of /usr/bin. Ubuntu 22.04's python is not externally managed:
# no --break-system-packages anywhere on this branch.
pip3 install -U pip setuptools wheel cmake

###################################
#    the bench's services         #
###################################
# Everything a unit runs at boot is a systemd unit the upgrade owns —
# supervised (restarted on failure), every line in the journal
# (persistent, below), restarted by the component step that refreshes
# its code. Both servers run on this one computer. Units run as root,
# as on the Pis (sudo set HOME=/root; the units say so explicitly).
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
Environment=HOME=/root PORT=80 PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-orchestrator
ExecStart=/usr/bin/python3 -u gui/server.py
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
Environment=HOME=/root PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-vision
ExecStart=/usr/bin/python3 -u -m dorna_vision.server --host 0.0.0.0 --port 4001
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
Environment=HOME=/root PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-jupyter
ExecStart=/usr/bin/python3 -m jupyter notebook --ip 0.0.0.0 --no-browser --port=8888 --allow-root --notebook-dir=/home/dorna/ --NotebookApp.token= --NotebookApp.password=
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
