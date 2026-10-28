### Jetson (workspace + vision on one computer)

For a Jetson Orin Nano Super running JetPack 7.2.1 (L4T R39, Ubuntu 24.04,
Python 3.12). The workspace orchestrator and the vision server both run
here, on the GPU computer — one unit instead of a workspace Pi and a
vision Pi.

> **Status (2026-10-28):** moved to JetPack 7.2.1 — CUDA 13.2, TensorRT
> 10.16, NVIDIA's OpenCV 4.8, one python venv; the first full run on a
> fresh unit is in progress. Still to add: the OCR models' fetch
> (`dorna_vision.ai.fetch_ocr()`) to the vision step. The full picture —
> models, training, setup, next steps: `dorna_vision` repo, `jetson`
> branch, `docs/jetson.md`.

Before the first upgrade, on a freshly installed unit (user `dorna`,
hostname `jetson`), give `dorna` passwordless sudo, as on the Pis:
```bash
echo "dorna ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_dorna-nopasswd && sudo chmod 440 /etc/sudoers.d/010_dorna-nopasswd
```

First-time upgrade (run the full command once):
```bash
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b jetson https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo bash setup.sh
```

After the first upgrade, the `upgrade` helper is installed. For future upgrades just run:
```bash
sudo upgrade
```

### What it installs

| component | source | notes |
|---|---|---|
| `os` | apt + pip | build tools, mosquitto, current pip/setuptools/cmake, MAXN SUPER power mode, the units |
| `dorna_python` | `dorna2-python` @ `master` | |
| `dorna_devices` | `dorna_devices` @ `main` | |
| `path_planning` | `path_planning` @ `main` | vcpkg pinned to a release tag, telemetry off; `python-fcl`, `urchin` |
| `librealsense` | `librealsense` @ pinned tag | RSUSB + CUDA + python binding; rebuilt only when the tag or flags change |
| `camera` | `camera` @ `master` | RealSense, IDS uEye, Hikrobot MVS |
| `vision` | `dorna_vision` @ `jetson` | the server and the client, one checkout |
| `workspace` | `workspace` @ `jetson` | |

numpy stays 1.x (`constraints.txt`): JetPack's OpenCV is built against it.

From NVIDIA's apt repo, only what the unit uses: nvcc + the CUDA runtime,
cuBLAS, cuSPARSE, NVRTC, TensorRT and its python binding, NVIDIA's OpenCV
4.8 and its cv2 — not the CUDA toolkit meta-package (profilers, debugger,
libraries nothing here uses).

### Python

Every python package lives in **one venv, `/opt/dorna/venv`**, created
with `--system-site-packages` so it sees apt's TensorRT, cv2 and numpy.
Ubuntu 24.04's own python packages belong to apt — pip cannot upgrade
one of them — so pip never touches them: it installs into the venv,
which shadows an apt package when a newer version is needed.

The venv is first on every PATH (`/etc/environment`: ssh, logins, cron;
`/etc/sudoers.d/020_dorna-venv`: sudo), so nothing changes in use:
`sudo python3`, `sudo pip3 install …`, Jupyter's kernel and the services
are all the venv's python.

### Services

Everything a unit runs at boot is a systemd unit the upgrade owns:
supervised — restarted on failure — with every line in the persistent
journal. `os/setup.sh` installs them; the component that refreshes a
unit's code restarts it.

| unit | what | port |
|---|---|---|
| `dorna-orchestrator` | `gui/server.py`, the workspace orchestrator | 80 |
| `dorna-vision` | `python3 -m dorna_vision.server` | 4001 |
| `dorna-jupyter` | the bench's Jupyter notebook | 8888 |

```bash
systemctl status dorna-vision                # running? since when? last restart?
journalctl -u dorna-vision -n 200 -f         # the live log
journalctl -b -1 -u dorna-orchestrator       # the previous boot's log
```

At the end of an upgrade the units are started and each must answer
(`systemctl is-active` and an HTTP reply) before the unit reboots; a
unit whose service is not up is left as it is, with the service's status
and journal printed — never shipped dark. Site-specific environment, if
ever needed, goes in `/etc/default/<unit>` (read when present).
