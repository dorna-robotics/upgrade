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

#####################
#    mosquitto      #
#####################
# MQTT broker + clients for device messaging.
apt install -y mosquitto mosquitto-clients
systemctl enable --now mosquitto

###################################
#    orchestrator as a service    #
###################################
# The orchestrator (gui/server.py) used to be launched from root's
# crontab via /home/dorna/startup.sh as a nohup'd background process —
# unsupervised (a crash waited for a reboot), its stdout block-buffered
# into an ever-growing server.log that lost days of output on SIGTERM,
# and still serving pre-upgrade code from memory after a git reset.
# Now a systemd unit: restarted on failure, every line in the journal
# (persistent, see below), restarted by the workspace step after the
# code is refreshed. Runs as root, as before (it binds :80).
# WorkingDirectory / ExecStart follow the workspace repo's layout
# (…/workspace/workspace, gui/server.py) — if server.py moves, the unit
# must follow. Site-specific environment (if ever needed) goes in
# /etc/default/dorna-orchestrator, read when present.
cat > /etc/systemd/system/dorna-orchestrator.service <<'UNIT'
[Unit]
Description=Dorna Workspace orchestrator (gui/server.py)
After=network-online.target
Wants=network-online.target

[Service]
# Runs as root today (binds :80); kept to minimise change.
WorkingDirectory=/home/dorna/Downloads/workspace/workspace
Environment=PORT=80 PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-orchestrator
ExecStart=/usr/bin/python3 -u gui/server.py
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

# remove ONLY the server launch from startup.sh; the Jupyter line and the
# cron entry stay (Jupyter is its own task). Idempotent: a second run
# matches nothing; a unit without a startup.sh is left alone.
[ -f /home/dorna/startup.sh ] && sed -i '/gui\/server\.py/d' /home/dorna/startup.sh || true

# enabled here so it comes up on the end-of-upgrade reboot; STARTED by
# the workspace step once the code is installed (a first-time upgrade has
# no workspace yet — starting it here would only crash-loop until then).
systemctl daemon-reload
systemctl enable dorna-orchestrator
