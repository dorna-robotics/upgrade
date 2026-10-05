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

The legacy launcher — root's `@reboot sudo sh /home/dorna/startup.sh`
with a nohup'd server and notebook inside — is retired by the upgrade:
the script is kept as `/home/dorna/startup.sh.pre-upgrade` for the
record, the cron entry is removed, and so is any Jupyter launcher in the
`dorna` user's crontab. Site-specific environment, if ever needed, goes
in `/etc/default/<unit>` (read when present).
