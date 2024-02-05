#!/bin/sh
TARGET_USER="vncuser1"

#Download the Repo defination
wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
mv virtualbox.repo /etc/yum.repos.d/

#Download the Oracle Keys
wget -q https://www.virtualbox.org/download/oracle_vbox.asc
rpm --import oracle_vbox.asc

#Install configure the Repo
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

echo "Installing VBOX"
dnf install -y VirtualBox-7.0
usermod -aG vboxusers root
usermod -aG vboxusers $TARGET_USER
/usr/lib/virtualbox/vboxdrv.sh setup

#Installl VBOX Extenstions
#cd ~/
#wget https://download.virtualbox.org/virtualbox/7.0.10/Oracle_VM_VirtualBox_Extension_Pack-7.0.10.vbox-extpack
#/sbin/vboxconfig

#VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack
