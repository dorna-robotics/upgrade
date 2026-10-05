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

####################################
#    vision server as a service    #
####################################
# The vision server (python3 -m dorna_vision.server) used to be launched
# from a startup script as a nohup'd background process — unsupervised
# (a crash waited for a reboot), its stdout block-buffered into a log
# that lost output on SIGTERM, and still serving pre-upgrade code from
# memory after a git reset. Now a systemd unit: restarted on failure,
# every line in the journal (persistent, see below), restarted by the
# vision step after the code is refreshed. Runs as root, as before (it
# binds :80, the port the workspaces' bench.j2 files name). Site-specific
# environment — DEVICE_MQTT_HOST for the site broker, for one — goes in
# /etc/default/dorna-vision, read when present.
cat > /etc/systemd/system/dorna-vision.service <<'UNIT'
[Unit]
Description=Dorna vision server (dorna_vision.server)
After=network-online.target
Wants=network-online.target

[Service]
# Runs as root today (binds :80); kept to minimise change.
WorkingDirectory=/home/dorna/Downloads/vision
Environment=PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-vision
ExecStart=/usr/bin/python3 -u -m dorna_vision.server --host 0.0.0.0 --port 80
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

# remove ONLY the server launch from startup.sh, where a unit has one;
# anything else in it (Jupyter) and the cron entry stay. The launch may
# span lines with backslash continuations ("exec python3 -m
# dorna_vision.server \\" / "    --host 0.0.0.0 --port 80 … >> $LOG"):
# join those first, drop the statement, drop any orphaned option line a
# previous edit left (a line beginning with "--" is never a command), and
# PROVE the result parses before it replaces the file — a half-edited
# launcher is never left for cron to trip on at reboot (10.0.1.40,
# 2026-10-05: "startup.sh: 13: --host: not found"). The original is kept
# beside it as startup.sh.pre-upgrade. Idempotent: a second run finds
# nothing to do; a unit without a startup.sh is left alone.
if [ -f /home/dorna/startup.sh ] && grep -Eq 'dorna_vision\.server|^[[:space:]]*--[a-z]' /home/dorna/startup.sh; then
    cp /home/dorna/startup.sh /home/dorna/startup.sh.pre-upgrade
    sed -e ':a' -e '/\\$/N; s/\\\n[[:space:]]*/ /; ta' /home/dorna/startup.sh \
        | sed -e '/dorna_vision\.server/d' -e '/^[[:space:]]*--[a-z]/d' > /home/dorna/startup.sh.new
    if sh -n /home/dorna/startup.sh.new && ! grep -q 'dorna_vision\.server' /home/dorna/startup.sh.new; then
        cat /home/dorna/startup.sh.new > /home/dorna/startup.sh
    else
        echo "WARNING: /home/dorna/startup.sh could not be edited cleanly — left unchanged, see startup.sh.new"
    fi
    rm -f /home/dorna/startup.sh.new
fi

# enabled here so it comes up on the end-of-upgrade reboot; STARTED by
# the vision step once the package is installed (a first-time upgrade has
# no dorna_vision yet — starting it here would only crash-loop until then).
systemctl daemon-reload
systemctl enable dorna-vision
