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
| `dorna-vision` | `python3 -m dorna_vision.server`, the vision server | 4001 |
| `dorna-jupyter` | the bench's Jupyter notebook | 8888 |

```bash
systemctl status dorna-vision          # running? since when? last restart?
journalctl -u dorna-vision -n 200 -f   # the live log
journalctl -b -1 -u dorna-vision       # the previous boot's log
```

At the end of an upgrade the units are started and each must answer
(`systemctl is-active` and an HTTP reply) before the unit reboots; a
unit whose service is not up is left as it is, with the service's status
and journal printed — never shipped dark. The RealSense binding, built
from source on a unit, is registered system-wide (a `.pth` in the system
site dir) so the service finds it without the `PYTHONPATH` only cron used
to carry.

The legacy launchers — root's `@reboot sudo sh /home/dorna/startup.sh`
with a nohup'd server inside, and the notebook's cron entry — are
retired by the upgrade: the script is kept as
`/home/dorna/startup.sh.pre-upgrade` for the record and the cron entries
are removed. Site-specific environment — `DEVICE_MQTT_HOST` for the
site's device-bus broker, for one — goes in `/etc/default/<unit>` (read
when present).

### The System page — upgrading from the browser

The vision server's **System** page (`http://<vision-pi>:4001/system`)
shows what this unit's upgrade installed, which parts have updates, and
runs `sudo upgrade` with its live log — through the restart and the
reboot — as the workspace's System page does on a workspace Pi.

It reads two files the upgrade writes:

- `/var/lib/dorna/upgrade.json` — the record: when the last upgrade ran,
  how it ended, and one entry per part, written by the part itself
  (`lib/record.sh`, sourced as each part's last line, from its `label`,
  `dir`, `repo`, `branch`). The list of parts lives only in `$upgrade`.
- `/etc/dorna/unit.json` — the unit's declaration,
  `{"system": "vision", "links": {"workspace": "http://{subnet}.20/"}}`
  (`os/setup.sh`): on this unit the vision server owns the System page,
  and its Workspace card opens the workspace Pi (.20 on this unit's
  subnet).
  A Jetson declares `"workspace"` — there the workspace's System page
  upgrades everything, the vision server's included, and the vision
  server shows none.
