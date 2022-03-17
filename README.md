# Upgrade

## Directory
```bash
~/Downloads
	|____ /upgrade
	|____ /dorna_lab
	|____ /dorna2_python

~/projects
	|____ /blockly
	|____ /script
	|____ /path_design
	|____ /python
```

## Manual upgrade
`ssh` to your robot, make sure that the robot has access to the internet and clone the latest `upgrade` repository:
```bash
sudo rm -rf ~/Downloads/upgrade
sudo mkdir ~/Downloads/upgrade  
sudo git clone https://github.com/dorna-robotics/upgrade.git ~/Downloads/upgrade
sudo python3 ~/Downloads/upgrade/main.py
```
sudo git pull https://github.com/dorna-robotics/upgrade.git

Make sure the robot is connected to the internet, and clone the latest `upgrade` repository:
`shekk
sudo git clone https://github.com/dorna-robotics/upgrade.git temp
sudo mv temp/.git ~/Downloads/upgrade/.git
sudo rm -rf temp
`

sudo git clone https://github.com/dorna-robotics/upgrade.git temp
sudo mv temp/.git ~/Downloads/upgrade/.git
sudo rm -rf temp


## Dorna python
sudo git clone --branch asyncio https://github.com/dorna-robotics/dorna2-python.git ~/pkg/dorna_python

## Dorna lab
sudo rm -r ~/pkg/dorna_lab
sudo git clone --branch blockly https://gitlab.com/smhty/dorna_lab.git ~/pkg/dorna_lab
cd ~/pkg/dorna_lab
sudo python3 setup.py install --force

## ngrok
Get the ARM version

cd ~/Downloads
sudo wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.tgz
sudo tar xvzf ~/Downloads/ngrok-stable-linux-arm.tgz -C /usr/local/bin

for ssh
	ngrok tcp 22
	gives you a forwarding url like this tcp://4.tcp.ngrok.io:18764
	ssh dorna@4.tcp.ngrok.io -p 18764

Once you ssh, you can use python to connect to the robot
For example robot.connect()

for http:
	you get the https address to access the robot