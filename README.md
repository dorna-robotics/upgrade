# Upgrade

## Manual upgrade
`ssh` to your robot, make sure that the robot has access to the internet and run the following series of commands in the terminal:
### config.txt
```bash
sudo sh -c 'printf "\ndtoverlay=pi3-miniuart-bt\nenable_uart=1\n" >> /boot/config.txt'
```

### raspi-config
```bash
sudo raspi-config
```
- Select "Interfacing Options"
- Select "Serial Port"
- Select "No"
- Select "Yes"
- Select "OK"
- Finish and reboot

### Dorna 2
```bash
sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b main https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh dorna_2
```

### Dorna 2S
```bash
sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b main https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh dorna_2s
```

### Dorna TA
```bash
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b dorna_ta https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh dorna_ta
```

### Vision Kit
```bash
sudo mkdir -p /home/dorna/Downloads && sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone -b vision https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh dorna_ta
```