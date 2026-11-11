#!/bin/bash

###################
#    variables    #
###################
# sh folders
upgrade="os dorna_python dorna_devices workspace path_planning vision_client"

# current dir
current_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

######################
#    check the OS    #
######################
# Get the version number from /etc/os-release
version=$(grep -oP '(?<=VERSION_ID=").*(?=")' /etc/os-release)

# Compare the version number
if dpkg --compare-versions "$version" lt 11; then
    echo "##################################################################################################################"
    echo "#    The Robot Operating System (OS) is outdated.                                                                #"
    echo "#    Before proceeding, please upgrade your robot controller OS to the latest version (version 12 or higher).    #"
    echo "##################################################################################################################"

    exit 1
fi

# install the `upgrade` helper command
cat > /usr/local/bin/upgrade <<'EOF'
#!/bin/bash
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b workspace https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo bash setup.sh
EOF
chmod +x /usr/local/bin/upgrade

# trust repo paths regardless of owner (root vs. dorna) so git fetch/reset in sub-setups can run
git config --global --add safe.directory '*'

######################
#    the record      #
######################
# /var/lib/dorna/upgrade.json — what this upgrade installed and how it
# ended; the admin's System page reads it. Each part writes its own entry
# (lib/record.sh, from the part's variables); this gathers them in the
# order of $upgrade with each part's exit code. The list of parts lives
# only in $upgrade.
record="/var/lib/dorna/upgrade.json"
export DORNA_UPGRADE_HOME="$current_dir"
export DORNA_UPGRADE_PARTS="$(mktemp -d)"
started="$(date -Iseconds)"
upgrade_commit="$(git -C "$current_dir" rev-parse HEAD 2>/dev/null || true)"
upgrade_branch="$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
write_record() {   # result  reason
    mkdir -p "$(dirname "$record")"
    python3 - "$1" "$2" "$started" "$upgrade_commit" "$upgrade_branch" "$upgrade" "$DORNA_UPGRADE_PARTS" "$record" <<'PY'
import datetime, json, os, sys
result, reason, started, commit, branch, order, parts_dir, out = sys.argv[1:9]
parts = []
for name in order.split():
    entry = {"name": name, "label": name}
    f = os.path.join(parts_dir, name + ".json")
    if os.path.exists(f):
        entry.update(json.load(open(f)))
    rc = os.path.join(parts_dir, name + ".rc")
    if os.path.exists(rc):
        entry["exit"] = int(open(rc).read().strip() or -1)
    parts.append(entry)
rec = {"started": started,
       "finished": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
       "result": result, "reason": reason,
       "upgrade": {"branch": branch, "commit": commit}, "parts": parts}
with open(out + ".tmp", "w") as f:
    json.dump(rec, f, indent=1)
os.replace(out + ".tmp", out)
PY
}

# Each part announces itself (`==> <part>`, the System page's progress)
# and keeps its exit code for the record.
for val in $upgrade; do
    echo "==> $val"
    cd $current_dir/$val
    export DORNA_UPGRADE_PART="$val"
    sh setup.sh $1
    echo "$?" > "$DORNA_UPGRADE_PARTS/$val.rc"
done

######################
#    services up     #
######################
echo "==> services"
# Every component is installed: the legacy processes go, the units start,
# and each must ANSWER before this unit is rebooted — a unit is never
# shipped dark (the breakages of 2026-10-05 would have stopped here).
health() {   # unit  url  seconds
    i=0
    while [ "$i" -lt "$3" ]; do
        if systemctl is-active --quiet "$1" && curl -sf -m 3 -o /dev/null "$2"; then
            echo "$1: up, answering at $2"
            return 0
        fi
        sleep 2; i=$((i + 2))
    done
    echo "#####################################################################"
    echo "#  $1 is NOT up after $3 s — the unit is left as it is, NO REBOOT.  #"
    echo "#####################################################################"
    systemctl status "$1" --no-pager 2>&1 | head -12
    journalctl -u "$1" -n 40 --no-pager 2>&1
    return 1
}
systemctl stop dorna-orchestrator dorna-jupyter 2>/dev/null || true
pkill -f 'python3 gui/server.py' || true               # a legacy nohup'd server holds :80
pkill -f 'jupyter-notebook|jupyter notebook' || true   # a legacy notebook holds :8888
systemctl start dorna-orchestrator dorna-jupyter || true
health dorna-orchestrator http://127.0.0.1/vendor/base.css 90 \
    || { write_record stopped "dorna-orchestrator was not up after 90 s — no reboot"; exit 1; }
health dorna-jupyter      http://127.0.0.1:8888/        60 \
    || { write_record stopped "dorna-jupyter was not up after 60 s — no reboot"; exit 1; }

######################
#    finalize        #
######################
# upgrade runs as root; restore ownership so the dorna service can write next to these files
chown -R dorna:dorna /home/dorna/Downloads
[ -d /home/dorna/Projects ] && chown -R dorna:dorna /home/dorna/Projects
# purge stale bytecode so python doesn't load pre-upgrade .pyc files against fresh source
find /home/dorna/Downloads -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

# the record, before this folder (and lib/) goes
write_record finished ""
rm -rf "$DORNA_UPGRADE_PARTS"

# remove the directory
rm -rf $current_dir

# sleep for 60 seconds
echo "Cleaning the buffer..."
sleep 30

# shutdown 
echo "###################################################"
echo "#    Setup process is now finished.               #"
echo "#    To finalize the update, follow these steps:  #"
echo "#      1. Wait for 30 seconds.                    #"
echo "#      2. Power cycle the controller.             #"
echo "###################################################"

# reboot
echo "==> reboot"
reboot
