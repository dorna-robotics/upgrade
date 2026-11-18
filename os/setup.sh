#!/bin/bash
set -e
# the name the upgrade's record shows (lib/record.sh)
label="OS"

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
#   dorna-vision    python3 -m dorna_vision.server on :4001
#   dorna-jupyter   the bench's notebook on :8888
# Both are ENABLED here and STARTED by the services step at the end of
# setup.sh, once every component is installed — and that step refuses to
# reboot a unit whose service does not answer.
# Site-specific environment — DEVICE_MQTT_HOST for the site's device-bus
# broker, for one — goes in /etc/default/<unit>, read when present.

# the vision server. :4001 — every vision server's port (the Jetson's too);
# the workspaces' bench.j2 files name it (vision_port = 4001).
# The Files page's folder — the operator's: /home/dorna/captures, dorna's,
# named to the service below. The server gives everything it writes there
# the folder's owner (dorna_vision/server/files.py), so captures are
# reachable from Jupyter and a shell. Captures from before, in the
# service's old default (/root/captures), move here once; a name already
# here is never overwritten — that entry stays in /root/captures, said so.
install -d -o dorna -g dorna /home/dorna/captures
if [ -d /root/captures ]; then
    for f in /root/captures/* /root/captures/.[!.]*; do
        [ -e "$f" ] || continue
        if [ -e "/home/dorna/captures/$(basename "$f")" ]; then
            echo "captures: kept /root/captures/$(basename "$f") — /home/dorna/captures has that name"
        else
            mv "$f" /home/dorna/captures/
        fi
    done
    chown -R dorna:dorna /home/dorna/captures
    rmdir /root/captures 2>/dev/null || true
fi

cat > /etc/systemd/system/dorna-vision.service <<'UNIT'
[Unit]
Description=Dorna vision server (dorna_vision.server)
After=network-online.target
Wants=network-online.target

[Service]
# Runs as root, as the old launch did.
WorkingDirectory=/home/dorna/Downloads/vision
Environment=HOME=/root PYTHONUNBUFFERED=1
EnvironmentFile=-/etc/default/dorna-vision
ExecStart=/usr/bin/python3 -u -m dorna_vision.server --host 0.0.0.0 --port 4001 --captures /home/dorna/captures
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
# as startup.sh.pre-upgrade for the record, and BOTH crontabs (root's,
# the dorna user's — units differ in which one ran it: "# startup",
# "# vision") lose the entry that ran it. The jupyter component's cron
# entry and its copied script go too (the unit owns :8888). A unit with
# none of these is left alone; crontab exits non-zero when a user has no
# crontab — never trips set -e.
[ -f /home/dorna/startup.sh ] && mv -f /home/dorna/startup.sh /home/dorna/startup.sh.pre-upgrade
( crontab -l 2>/dev/null | grep -v -i -e 'startup\.sh' -e 'jupyter' | crontab - ) 2>/dev/null || true
( crontab -u dorna -l 2>/dev/null | grep -v -i -e 'startup\.sh' -e 'jupyter' | crontab -u dorna - ) 2>/dev/null || true
rm -rf /home/dorna/Downloads/jupyter

systemctl daemon-reload
systemctl enable dorna-vision dorna-jupyter

#############################
#    the unit's declaration #
#############################
# What this unit is, for the apps that read it: on a vision Pi the vision
# server owns the System page (the upgrade, from the browser) — on a
# workspace Pi or a Jetson the workspace does, and the vision server shows
# none. `links`: where the vision server's Workspace card points — {subnet}
# is the first three octets of the address the browser reached the page by.
# A two-Pi unit: the workspace Pi at .20 (the robot at .10, this Pi at .40).
# Declared per unit type, never guessed.
install -d /etc/dorna
cat > /etc/dorna/unit.json <<'JSON'
{"system": "vision", "links": {"workspace": "http://{subnet}.20/"}}
JSON

#####################
#    the record     #
#####################
# this part, as installed, in the upgrade's record (lib/record.sh)
[ -z "${DORNA_UPGRADE_HOME:-}" ] || . "$DORNA_UPGRADE_HOME/lib/record.sh"
