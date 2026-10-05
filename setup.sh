#!/bin/bash

###################
#    variables    #
###################
# sh folders
upgrade="os dorna_python dorna_devices vision camera"

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
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b vision_pro https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh
EOF
chmod +x /usr/local/bin/upgrade

# trust repo paths regardless of owner (root vs. dorna) so git fetch/reset in sub-setups can run
git config --global --add safe.directory '*'

for val in $upgrade; do
    cd $current_dir/$val
    sh setup.sh $1
done

######################
#    services up     #
######################
# Every component is installed: the legacy processes go, the units start,
# and each must ANSWER before this unit is rebooted — a unit is never
# shipped dark (both breakages of 2026-10-05 would have stopped here).
# The vision server may take a while to find its cameras: 120 s.
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
systemctl stop dorna-vision dorna-jupyter 2>/dev/null || true
pkill -f 'dorna_vision.server' || true                 # a legacy nohup'd server holds :80
pkill -f 'jupyter-notebook|jupyter notebook' || true   # a legacy notebook holds :8888
systemctl start dorna-vision dorna-jupyter || true
health dorna-vision  http://127.0.0.1/      120 || exit 1
health dorna-jupyter http://127.0.0.1:8888/  60 || exit 1

######################
#    finalize        #
######################
# upgrade runs as root; restore ownership so the dorna service can write next to these files
chown -R dorna:dorna /home/dorna/Downloads
[ -d /home/dorna/Projects ] && chown -R dorna:dorna /home/dorna/Projects
# purge stale bytecode so python doesn't load pre-upgrade .pyc files against fresh source
find /home/dorna/Downloads -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

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
reboot