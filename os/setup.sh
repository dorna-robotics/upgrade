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
# cron entry stay (Jupyter is its own task). The launch may span lines
# with backslash continuations ("exec python3 … \\" / "    --host … >> $LOG"):
# join those first, drop the statement, drop any orphaned option line a
# previous edit left (a line beginning with "--" is never a command), and
# PROVE the result parses before it replaces the file — a half-edited
# launcher is never left for cron to trip on at reboot (the field unit
# 10.0.1.40, 2026-10-05: "startup.sh: 13: --host: not found"). The
# original is kept beside it as startup.sh.pre-upgrade. Idempotent: a
# second run finds nothing to do; a unit without a startup.sh is left alone.
if [ -f /home/dorna/startup.sh ] && grep -Eq 'gui/server\.py|^[[:space:]]*--[a-z]' /home/dorna/startup.sh; then
    cp /home/dorna/startup.sh /home/dorna/startup.sh.pre-upgrade
    sed -e ':a' -e '/\\$/N; s/\\\n[[:space:]]*/ /; ta' /home/dorna/startup.sh \
        | sed -e '/gui\/server\.py/d' -e '/^[[:space:]]*--[a-z]/d' > /home/dorna/startup.sh.new
    if sh -n /home/dorna/startup.sh.new && ! grep -q 'gui/server\.py' /home/dorna/startup.sh.new; then
        cat /home/dorna/startup.sh.new > /home/dorna/startup.sh
    else
        echo "WARNING: /home/dorna/startup.sh could not be edited cleanly — left unchanged, see startup.sh.new"
    fi
    rm -f /home/dorna/startup.sh.new
fi

# enabled here so it comes up on the end-of-upgrade reboot; STARTED by
# the workspace step once the code is installed (a first-time upgrade has
# no workspace yet — starting it here would only crash-loop until then).
systemctl daemon-reload
systemctl enable dorna-orchestrator
