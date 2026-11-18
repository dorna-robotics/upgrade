#!/bin/bash
set -e
###################
#    variables    #
###################
dir="/home/dorna/Downloads/vision"
repo="https://github.com/dorna-robotics/dorna_vision"
branch="pro"
label="Vision"            # the name the upgrade's record shows (lib/record.sh)

########################
#    clone or pull     #
########################
sync_repo() {
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        if git fetch origin "$branch" \
            && git checkout -B "$branch" "origin/$branch" \
            && git reset --hard "origin/$branch"; then
            git clean -fd
            return 0
        fi
        cd /
    fi
    rm -rf "$dir"
    git clone -b "$branch" "$repo" "$dir"
    cd "$dir"
}
sync_repo

# install requirements (if present)
if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
fi

#################
#    install    #
#################
# editable install — the server with the Jetson's engine (TensorRT), and
# the client the workspace imports (one checkout serves both on this
# computer)
pip3 install -e ".[jetson]"
pip3 install -e dorna_vision-client

# the built-in models — OCR and the classifier backbone: downloaded
# (pinned, checksum verified) and their TensorRT engines built — once per
# unit; after that, nothing
python3 -c 'from dorna_vision.ai import fetch; print("built-in models", fetch())'

#####################
#    the record     #
#####################
# this part, as installed, in the upgrade's record (lib/record.sh)
[ -z "${DORNA_UPGRADE_HOME:-}" ] || . "$DORNA_UPGRADE_HOME/lib/record.sh"
