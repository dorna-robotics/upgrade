### Workspace

First-time upgrade (run the full command once):
```bash
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b workspace https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo bash setup.sh
```

After the first upgrade, the `upgrade` helper is installed. For future upgrades just run:
```bash
sudo upgrade
```

### Services

Everything a unit runs at boot is a systemd unit the upgrade owns:
supervised — restarted on failure — with every line in the persistent
journal. `os/setup.sh` installs them; the component that refreshes a
unit's code restarts it.

| unit | what | port |
|---|---|---|
| `dorna-orchestrator` | `gui/server.py`, the workspace orchestrator | 80 |
| `dorna-jupyter` | the bench's Jupyter notebook | 8888 |

```bash
systemctl status dorna-orchestrator          # running? since when? last restart?
journalctl -u dorna-orchestrator -n 200 -f   # the live log
journalctl -b -1 -u dorna-orchestrator       # the previous boot's log
```

At the end of an upgrade the units are started and each must answer
(`systemctl is-active` and an HTTP reply) before the unit reboots; a
unit whose service is not up is left as it is, with the service's status
and journal printed — never shipped dark.

The legacy launcher — root's `@reboot sudo sh /home/dorna/startup.sh`
with a nohup'd server and notebook inside — is retired by the upgrade:
the script is kept as `/home/dorna/startup.sh.pre-upgrade` for the
record, the cron entry is removed, and so is any Jupyter launcher in the
`dorna` user's crontab. Site-specific environment, if ever needed, goes
in `/etc/default/<unit>` (read when present).

### The unit's declaration

`os/setup.sh` writes `/etc/dorna/unit.json`, what this unit is, declared
per unit type instead of guessed by the apps: `system` — the app that
owns the System page (the upgrade, from the browser); `links` — where the
workspace's Dorna Lab and Vision cards and nav item point. `{host}` is the
address the browser reached the page by, `{subnet}` its first three
octets. A two-Pi unit:

```json
{"system": "workspace", "links": {"dorna_lab": "http://{subnet}.10/", "vision": "http://{subnet}.40:4001/"}}
```

The vision Pi serves on :4001 (its own upgrade, branch `vision_pro`); a
project's `scene/bench.j2` names the same port (`vision_port = 4001`).

### The record — the admin's System page

Every upgrade writes `/var/lib/dorna/upgrade.json`: when it started and
ended, how (`finished` — the reboot was reached — or `stopped` and why),
and one entry per part, in the order of `$upgrade` in `setup.sh`:

```json
{"name": "workspace", "label": "Workspace", "dir": "/home/dorna/Downloads/workspace",
 "repo": "https://github.com/dorna-robotics/workspace", "branch": "main",
 "commit": "5a1a31be…", "exit": 0}
```

Each part writes its own entry: its `setup.sh` declares `label` (and, if
it installs a repo, `dir`, `repo`, `branch` — as before) and ends with

```bash
[ -z "${DORNA_UPGRADE_HOME:-}" ] || . "$DORNA_UPGRADE_HOME/lib/record.sh"
```

`setup.sh` gathers the entries with each part's exit code, and prints
`==> <part>` before each part (then `==> services`, `==> reboot`) — the
System page's progress. **To add a part:** a folder with its `setup.sh`
(those variables + that last line), and its name in `$upgrade`. The
workspace's System page lists it after the next upgrade; nothing there
names a part. Run by hand, a part's `setup.sh` records nothing.

