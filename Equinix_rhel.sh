#!/bin/sh

yum -y install tigervnc-server tigervnc
yum -y group install GNOME base-x
yum -y groupinstall "Server with GUI"
systemctl set-default graphical.target
systemctl isolate graphical.target


#Create the User Env
useradd vncuser1
#passwd vnc
mkdir -p /home/vncuser1/.vnc
touch /home/vncuser1/.vnc/config
echo 'session=gnome' > /home/vncuser1/.vnc/config
echo ':1=vncuser1' >> /etc/tigervnc/vncserver.users
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service

#set the password
#mkdir -p /home/vncuser1/.vnc && x11vnc -storepasswd admin /home.vncuser1/.vnc/passwd

#open the ports
firewall-cmd --permanent --zone=public --add-port 5901/tcp
firewall-cmd  --reload





