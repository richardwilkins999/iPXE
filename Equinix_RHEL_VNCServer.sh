#!/bin/sh

# The userid who will run VNC
read -p "Please enter the UserID for VNC:" TARGET_USER

# Ask user Password
read -p "Please enter the Password for $TARGET_USER:" TARGET_USER_PASSWORD

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
echo "Opening FW Ports"
firewall-cmd --permanent --zone=public --add-port 5901/tcp
firewall-cmd  --reload

#Do not Start the VNCServer, in the script
echo "Please start VNC manually and set the VNCPassword by running the following commands"
echo "su - $TARGET_USER"
echo "vncserver"

exit
