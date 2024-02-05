#!/bin/sh

#Interface Name
IF_NAME="bond0"

# The userid who will run VNC
read -p "Please enter the UserID for VNC:" TARGET_USER

# Ask user for the VLAN ID
read -p  "Please enter the VLAN ID for $IF_NAME:" VLAN_ID

# Ensure the VLAN ID is provided
if [ -z "$VLAN_ID" ]; then
    echo "VLAN ID is required. Exiting."
    exit 1
fi

dnf install virt-install virt-viewer -y
dnf install -y libvirt
dnf install virt-manager -y
dnf install -y virt-top libguestfs-tools
systemctl start libvirtd
systemctl enable libvirtd

#Enable the Virtmanager UI to run as non-root
usermod --append --groups libvirt $TARGET_USER

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

exit
