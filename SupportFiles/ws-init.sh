#!/bin/bash

# Install GNOME
yum -y groups install 'GNOME Desktop'
systemctl set-default graphical.target

# Install VNC server
yum -y install tigervnc-server

# Generate default VNC server password
umask 0077
mkdir -p /home/ProvisionUser/.vnc
chmod go-rwx /home/ProvisionUser/.vnc
vncpasswd -f <<<VNCServerPasswd> /home/ProvisionUser/.vnc/passwd
chown -R ProvisionUser:ProvisionUser /home/ProvisionUser/.vnc

# Configure VNC server
cp /lib/systemd/system/vncserver@.service  /etc/systemd/system/vncserver@:1.service
sed -i 's/<USER>/ProvisionUser/g' /etc/systemd/system/vncserver@:1.service
systemctl daemon-reload
systemctl start vncserver@:1
systemctl enable vncserver@:1

# Add firewall VNC server firewall rules
setenforce 0
firewall-cmd --add-port=5901/tcp
firewall-cmd --add-port=5901/tcp --permanent
setenforce 1