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

###################################
#    the bench's services         #
###################################
# Everything a unit runs at boot is a systemd unit the upgrade owns —
# supervised (restarted on failure), every line in the journal
# (persistent, below), restarted by the component step that refreshes
# its code. Nothing is launched from a hand-made startup script any more:
# the legacy launcher (root's "@reboot sudo sh /home/dorna/startup.sh"
# and the script, a nohup'd server with its stdout block-buffered into an
# ever-growing log, lost on SIGTERM, unsupervised, serving pre-upgrade
# code from memory after a git reset) is RETIRED below — archived, never
# edited: an edit once left a half-launcher for cron to trip on at reboot
# (10.0.1.40, 2026-10-05: "startup.sh: 13: --host: not found"). Units run
# as root, as the old launch did (sudo set HOME=/root; the units say so).
#   dorna-vision    python3 -m dorna_vision.server on :80 — started by vision/setup.sh
#   dorna-jupyter   the bench's notebook on :8888 — started here
# Site-specific environment — DEVICE_MQTT_HOST for the site's device-bus
# broker, for one — goes in /etc/default/<unit>, read when present.

# the vision server. :80 is the port the workspaces' bench.j2 files name.
# ENABLED here, STARTED by the vision step once the package is installed:
# a first-time upgrade has no dorna_vision yet.
cat > /etc/systemd/system/dorna-vision.service <<'UNIT'
[Unit]
Description=Dorna vision server (dorna_vision.server)
After=network-online.target
Wants=network-online.target

[Service]
# Runs as root today (binds :80); kept to minimise change.
WorkingDirectory=/home/dorna/Downloads/vision
Environment=HOME=/root PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-vision
ExecStart=/usr/bin/python3 -u -m dorna_vision.server --host 0.0.0.0 --port 80
Restart=on-failure
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

# Jupyter — the same notebook the jupyter component ran from cron, now a unit.
pip3 install notebook --break-system-packages
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

# retire the legacy launchers — not edited, ARCHIVED: the script is kept
# as startup.sh.pre-upgrade for the record, and root's crontab loses the
# entry that ran it. The jupyter component's cron entry in the dorna
# user's crontab and its copied script go too (the unit owns :8888). A
# unit with none of these is left alone; crontab exits non-zero when a
# user has no crontab — never trips set -e.
[ -f /home/dorna/startup.sh ] && mv -f /home/dorna/startup.sh /home/dorna/startup.sh.pre-upgrade
( crontab -l 2>/dev/null | grep -v 'startup\.sh' | crontab - ) 2>/dev/null || true
( crontab -u dorna -l 2>/dev/null | grep -v -i 'jupyter' | crontab -u dorna - ) 2>/dev/null || true
rm -rf /home/dorna/Downloads/jupyter

# the units: the vision server enabled (started by vision/setup.sh);
# Jupyter started now, after the legacy notebook (it holds :8888) is gone.
systemctl daemon-reload
systemctl enable dorna-vision
pkill -f 'jupyter-notebook|jupyter notebook' || true
systemctl enable dorna-jupyter
systemctl restart dorna-jupyter || true
