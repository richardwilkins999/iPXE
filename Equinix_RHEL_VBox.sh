#!/bin/sh
TARGET_USER="vncuser1"

# Ask user for the VLAN ID
echo "Please enter the VLAN ID:"
read VLAN_ID

# Ensure the VLAN ID is provided
if [ -z "$VLAN_ID" ]; then
    echo "VLAN ID is required. Exiting."
    exit 1
fi

#Download the Repo defination
wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
mv virtualbox.repo /etc/yum.repos.d/

#Download the Oracle Keys
wget -q https://www.virtualbox.org/download/oracle_vbox.asc
rpm --import oracle_vbox.asc

#Install configure the Repo
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#Install Kernal debug
dnf install -y kernel-devel kernel-devel-4.18.0-513.9.1.el8_9.x86_64

echo "Installing VBOX"
dnf install -y VirtualBox-7.0
usermod -aG vboxusers root
usermod -aG vboxusers $TARGET_USER
/usr/lib/virtualbox/vboxdrv.sh setup

#Installl VBOX Extenstions
wget https://download.virtualbox.org/virtualbox/7.0.10/Oracle_VM_VirtualBox_Extension_Pack-7.0.10.vbox-extpack
/sbin/vboxconfig

VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack

#Install the Vlan Tagging
#dnf install vlan
modprobe 8021q
touch /etc/modules-load.d/8021q.conf
echo "8021q" | tee /etc/modules-load.d/8021q.conf

ip link add link bond0 name $IF_NAME.$VLAN_ID type vlan id $VLAN_ID
ip link set dev $IF_NAME.$VLAN_ID up

#Make the VLAN permenent
cat > /etc/sysconfig/network-scripts/ifcfg-$IF_NAME.$VLAN_ID <<EOF
DEVICE=$IF_NAME.$VLAN_ID
BOOTPROTO=none
ONBOOT=yes
VLAN=yes
EOF


PUBLIC_IP=$(curl -s https://metadata.platformequinix.com/metadata | jq -r ".network.addresses[] | select(.public == true) | select(.address_family == 4) | .address")
echo "Public IP is : $PUBLIC_IP"
