#!/bin/bash
	 
# Generate default VNC server password
umask 0077
mkdir -p /home/maintuser/.vnc
chmod go-rwx /home/maintuser/.vnc
vncpasswd -f <<<vnc123 > /home/maintuser/.vnc/passwd
chown -R maintuser:maintuser /home/maintuser/.vnc

# Configure VNC server
cp /lib/systemd/system/vncserver@.service  /etc/systemd/system/vncserver@:1.service
sed -i 's/<USER>/maintuser/g' /etc/systemd/system/vncserver@:1.service
systemctl daemon-reload
systemctl start vncserver@:1
systemctl enable vncserver@:1

# Add firewall VNC server firewall rules
setenforce 0
firewall-cmd --add-port=5901/tcp
firewall-cmd --add-port=5901/tcp --permanent
setenforce 1
