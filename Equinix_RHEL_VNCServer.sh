#!/bin/sh

# The username for whom to set the VNC password
TARGET_USER="vncuser1"
TARGET_USER_PASSWORD="admin"

yum -y install tigervnc-server tigervnc
yum -y group install GNOME base-x
yum -y groupinstall "Server with GUI"
systemctl set-default graphical.target
systemctl isolate graphical.target

#Create the User Env
echo "Creating user:"$TARGET_USER
useradd -m $TARGET_USER && echo '$TARGET_USER:$TARGET_USER_PASSWORD' | chpasswd

#set VNC Env
mkdir -p /home/$TARGET_USER/.vnc
chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.vnc
touch /home/$TARGET_USER/.vnc/config
echo 'session=gnome' > /home/$TARGET_USER/.vnc/config
echo ':1=$TARGET_USER' >> /etc/tigervnc/vncserver.users
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service

#open the ports
firewall-cmd --permanent --zone=public --add-port 5901/tcp
firewall-cmd  --reload

#Do not Start the VNCServer, in the script
echo "Please start manually as the VNCUser and then set the VNCPassword
echo "su - $TARGET_USER"
echo "vncserver"

exit
