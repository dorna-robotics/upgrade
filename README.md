### Dorna vision

First-time upgrade (run the full command once):
```bash
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b vision_pro https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh
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
| `dorna-vision` | `python3 -m dorna_vision.server`, the vision server | 80 |
| `dorna-jupyter` | the bench's Jupyter notebook | 8888 |

```bash
systemctl status dorna-vision          # running? since when? last restart?
journalctl -u dorna-vision -n 200 -f   # the live log
journalctl -b -1 -u dorna-vision       # the previous boot's log
```

The legacy launchers — root's `@reboot sudo sh /home/dorna/startup.sh`
with a nohup'd server inside, and the notebook's cron entry — are
retired by the upgrade: the script is kept as
`/home/dorna/startup.sh.pre-upgrade` for the record and the cron entries
are removed. Site-specific environment — `DEVICE_MQTT_HOST` for the
site's device-bus broker, for one — goes in `/etc/default/<unit>` (read
when present).
