# Upgrade

## Directory
```bash
~/projects
	|____ /blockly
	|____ /script
	|____ /path_design
	|____ /python
```

## Manual upgrade
`ssh` to your robot, make sure that the robot has access to the internet and run the following series of commands in the terminal:
```bash
sudo rm -rf /home/dorna/Downloads/upgrade && sudo mkdir /home/dorna/Downloads/upgrade && sudo git clone https://github.com/dorna-robotics/upgrade.git /home/dorna/Downloads/upgrade && cd /home/dorna/Downloads/upgrade && sudo sh setup.sh
```

## ngrok
Get the ARM version

```bash
cd ~/Downloads
sudo wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.tgz
sudo tar xvzf ~/Downloads/ngrok-stable-linux-arm.tgz -C /usr/local/bin
```
for ssh
	ngrok tcp 22
	gives you a forwarding url like this tcp://4.tcp.ngrok.io:18764
	ssh dorna@4.tcp.ngrok.io -p 18764

Once you ssh, you can use python to connect to the robot
For example robot.connect()

for http:
	you get the https address to access the robot