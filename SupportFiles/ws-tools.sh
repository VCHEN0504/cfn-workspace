#!/bin/bash

# The "StackName" will be replaced with the AWS::StackName during runtime
function err_exit {
	echo "${1}"
	logger -p kern.crit -t ws-tools.sh "${1}"
	/opt/aws/bin/cfn-signal -e 1 --stack StackName --resource Ec2instance
	exit 1
}

# Install GNOME
yum -y groups install 'GNOME Desktop' || err_exit "Failed to install GNOME Desktop."
systemctl set-default graphical.target

# Install VNC server
yum -y install tigervnc-server || err_exit "Failed to install TigerVNC Server."

# Generate default VNC server password
# The "VNCServerPaswd" will be replaced with the VNCServerPasswd parameter and "ProvisionUser" with the ProvisionUser parameter in the CFN during runtime
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

# Unzip the tools.tar.gz
tar xfz /etc/cfn/tools/tools.tar.gz -C /etc/cfn/tools || err_exit "Failed to unzip tools.tar.gz"

# Install ATOM
# Launch it from your terminal by running the command "atom"
yum -y install /etc/cfn/tools/atom.x86_64.rpm || err_exit "Failed to install ATOM"

# (May not need to do this) Put it in the user's .local/share/applications/atom.desktop
#cp /usr/share/applications/atom.desktop /home/ProvisionUser/.local/share/applications/atom.desktop
#chmod go-rwx /home/ProvisionUser/.local/share/applications
#chown -R ProvisionUser:ProvisionUser /home/ProvisionUser/.local/share/applications

#Install Eclipse NEON IDE for Java EE Developers
tar xfz /etc/cfn/tools/eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz -C /opt/ || err_exit "Failed to unzip eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz"
ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
cp /etc/cfn/tools/eclipse.desktop /usr/share/applications/eclipse.desktop
cp /etc/cfn/tools/eclipse.desktop /home/maintuser/.local/share/applications/eclipse.desktop
chmod 755 /home/maintuser/.local/share/applications/eclipse.desktop

#Install Intellij
tar xfz /etc/cfn/tools/ideaIC-2018.3.3.tar.gz -C /opt/ || err_exit "Failed to unzip ideaIC-2018.3.3.tar.gz"
ln -s /opt/idea-IC-183.5153.38/bin/idea.sh /usr/local/bin/idea.sh

#Install emacs
yum -y install emacs || err_exit "Failed to install emacs"

