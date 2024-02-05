#!/bin/sh

# The userid who will run VNC
read -p "Please enter the UserID for VNC : " TARGET_USER

# Ask user Password for VNC User
read -p "Please enter the Password for $TARGET_USER : " TARGET_USER_PASSWORD

#Interface Name
IF_NAME="bond0"

# Ask user for the VLAN ID
read "Please enter the VLAN ID to attach to $IF_NAME : " VLAN_ID

# Ensure the VLAN ID is provided
if [ -z "$VLAN_ID" ]; then
    echo "VLAN ID is required. Exiting."
    exit 1
fi

### Install VNC
yum -y install tigervnc-server tigervnc
yum -y group install GNOME base-x
yum -y groupinstall "Server with GUI"
systemctl set-default graphical.target
systemctl isolate graphical.target

#Create the User Env
echo "Creating user : "$TARGET_USER
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

#### Install VBOX

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

#Install the Vlan Tagging
#dnf install vlan
modprobe 8021q
touch /etc/modules-load.d/8021q.conf
echo "8021q" | tee /etc/modules-load.d/8021q.conf

ip link add link $IF_NAME name $IF_NAME.$VLAN_ID type vlan id $VLAN_ID
ip link set dev $IF_NAME.$VLAN_ID up

#Make the VLAN permenent
cat > /etc/sysconfig/network-scripts/ifcfg-$IF_NAME.$VLAN_ID <<EOF
DEVICE=$IF_NAME.$VLAN_ID
BOOTPROTO=none
ONBOOT=yes
VLAN=yes
EOF

#removing for now
dnf -y update
dnf -y upgrade

#Reboot after config
#systemctl reboot

#print public IP address
dnf install -y jq
PUBLIC_IP=$(curl -s https://metadata.platformequinix.com/metadata | jq -r ".network.addresses[] | select(.public == true) | select(.address_family == 4) | .address")
echo "Public IP is : $PUBLIC_IP"

#Please manually install the VBOX extensions
echo "VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack"
echo ""

#Do not Start the VNCServer, in the script
echo "Please start VNC manually and set the VNCPassword by running the following commands"
echo "su - $TARGET_USER"
echo "vncserver"

exit
