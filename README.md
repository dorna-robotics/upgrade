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

The vision server (`python3 -m dorna_vision.server`, port 80) runs as
the systemd unit `dorna-vision` (installed by `os/setup.sh`, restarted
by `vision/setup.sh` once the code is refreshed): supervised — restarted
on failure — with every line in the persistent journal.

```bash
systemctl status dorna-vision          # running? since when? last restart?
journalctl -u dorna-vision -n 200 -f   # the live log
journalctl -b -1 -u dorna-vision       # the previous boot's log
```

A `dorna_vision.server` launch line in `/home/dorna/startup.sh`, where a
unit has one, is removed by the upgrade; anything else in it stays.
Site-specific environment — `DEVICE_MQTT_HOST` for the site's device-bus
broker, for one — goes in `/etc/default/dorna-vision` (read when present).
