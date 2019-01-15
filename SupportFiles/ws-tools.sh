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

# Install Anaconda
bash /etc/cfn/tools/anaconda/anaconda.sh -b -p /home/maintuser/anaconda3
chown -R maintuser:maintuser /home/maintuser/anaconda3

cp /etc/cfn/tools/anaconda/anaconda.desktop /usr/share/applications/anaconda.desktop
cp /etc/cfn/tools/anaconda/anaconda.desktop /home/maintuser/.local/share/applications/anaconda.desktop
chown maintuser:maintuser /home/maintuser/.local/share/applications/anaconda.desktop
chmod 600 /home/maintuser/.local/share/applications/anaconda.desktop

# Install ATOM
# Launch it from your terminal by running the command "atom"
yum -y install /etc/cfn/tools/atom/atom.x86_64.rpm || err_exit "Failed to install ATOM"

#Install Eclipse NEON IDE for Java EE Developers
tar xfz /etc/cfn/tools/eclipse/eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz -C /opt/ || err_exit "Failed to unzip eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz"
ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse

cp /etc/cfn/tools/eclipse/eclipse.desktop /usr/share/applications/eclipse.desktop
cp /etc/cfn/tools/eclipse/eclipse.desktop /home/maintuser/.local/share/applications/eclipse.desktop
chown maintuser:maintuser /home/maintuser/.local/share/applications/eclipse.desktop
chmod 600 /home/maintuser/.local/share/applications/eclipse.desktop

#Install Intellij
tar xfz /etc/cfn/tools/intellij/ideaIC-2018.3.3.tar.gz -C /opt/ || err_exit "Failed to unzip ideaIC-2018.3.3.tar.gz"
chmod -R 755 /opt/idea-IC-183.5153.38
ln -s /opt/idea-IC-183.5153.38/bin/idea.sh /usr/local/bin/idea

cp /etc/cfn/tools/intellij/jetbrains-idea-ce.desktop /usr/share/applications/jetbrains-idea-ce.desktop
cp /etc/cfn/tools/intellij/jetbrains-idea-ce.desktop /home/maintuser/.local/share/applications/jetbrains-idea-ce.desktop
chown maintuser:maintuser /home/maintuser/.local/share/applications/jetbrains-idea-ce.desktop
chmod 600 /home/maintuser/.local/share/applications/jetbrains-idea-ce.desktop

#Install emacs
yum -y install emacs || err_exit "Failed to install emacs"

#Install Gradle
unzip -d /opt/ /etc/cfn/tools/gradle/gradle-5.1.1-bin.zip
chmod -R 755 /opt/gradle-5.1.1
ln -s /opt/gradle-5.1.1/bin/gradle /usr/local/bin/gradle

# Install Maven
yum -y install maven || err_exit "Failed to install maven"

# Install git
yum -y install git  || err_exit "Failed to install git"
yum -y install git-gui || err_exit "Failed to install git-gui"

# Install ruby
yum -y install ruby || err_exit "Failed to install ruby"

# Install node.js
tar -xvf  /etc/cfn/tools/nodejs/node-v11.6.0-linux-x64.tar.xz -C /opt
chmod -R 755 /opt/node-v11.6.0-linux-x64
ln -s /opt/node-v11.6.0-linux-x64/bin/node /usr/bin/node
ln -s /opt/node-v11.6.0-linux-x64/bin/npm /usr/bin/npm

# Install pycharm
tar -xvf  /etc/cfn/tools/pycharm/pycharm-community-2018.3.3.tar.gz -C /opt
chmod -R 755 /opt/pycharm-community-2018.3.3
ln -s /opt/pycharm-community-2018.3.3/bin/pycharm.sh /usr/local/bin/pycharm 

cp /etc/cfn/tools/pycharm/pycharm.desktop /usr/share/applications/pycharm.desktop
cp /etc/cfn/tools/pycharm/pycharm.desktop /home/maintuser/.local/share/applications/pycharm.desktop
chown maintuser:maintuser /home/maintuser/.local/share/applications/pycharm.desktop
chmod 600 /home/maintuser/.local/share/applications/pycharm.desktop                                                       

#cp /etc/cfn/tools/gradle/gradle.sh  /etc/profile.d/gradle.sh
#chmod 755 /etc/profile.d/gradle.sh

#ln -s /opt/gradle/gradle-5.1.1/bin/gradle /usr/local/bin/gradle

# (TODO) add app to PATH
# sed -i 's;^PATH=.*;PATH='"$PATH"';' .bashrc
# echo 'export PATH=/usr/local/bin:$PATH' >>~/.bash_profile

