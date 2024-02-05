#!/bin/sh

#Download the Repo defination
wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
mv virtualbox.repo /etc/yum.repos.d/

#Download the Oracle Keys
wget -q https://www.virtualbox.org/download/oracle_vbox.asc
rpm --import oracle_vbox.asc

#Install configure the Repo
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

echo "Installing VBOX"
dnf install -y VirtualBox
