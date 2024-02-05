#!/bin/sh

# The userid and password of who will run VNC and VirtMgr
read -p "Please enter the UserID for VNC:" TARGET_USER
read -p "Please enter the Password for $TARGET_USER:" TARGET_USER_PASSWORD

# Ask user for the VLAN ID
read -p  "Please enter the VLAN ID for $IF_NAME:" VLAN_ID

# Ensure the VLAN ID is provided
if [ -z "$VLAN_ID" ]; then
    echo "VLAN ID is required. Exiting."
    exit 1
fi

#Set to default Interface for Equinix
IF_NAME="bond0"

##Install VNC
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

### Install VirtMgr
dnf -y install virt-install virt-viewer libvirt virt-top libguestfs-tools
dnf -y install virt-manager
systemctl start libvirtd
systemctl enable libvirtd

#Enable the Virtmanager UI to run as non-root
usermod --append --groups libvirt $TARGET_USER

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

#print public IP address
dnf -y install jq
PUBLIC_IP=$(curl -s https://metadata.platformequinix.com/metadata | jq -r ".network.addresses[] | select(.public == true) | select(.address_family == 4) | .address")
echo "Public IP is : $PUBLIC_IP"

#Do not Start the VNCServer, in the script
echo "Please start VNC manually and set the VNCPassword by running the following commands"
echo "su - $TARGET_USER"
echo "vncserver"
exit
