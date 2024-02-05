#!/bin/sh

# The userid who will run VNC
read -p "Please enter the UserID for VNC:" TARGET_USER

#Interface Name
IF_NAME="bond0"

# Ask user for the VLAN ID
echo "Please enter the VLAN ID:"
read VLAN_ID

# Ensure the VLAN ID is provided
if [ -z "$VLAN_ID" ]; then
    echo "VLAN ID is required. Exiting."
    exit 1
fi

#Just to be sure
apt -y update
apt -y install qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

#Allow the user access to KVM
adduser $TARGET_USER libvirt
adduser $TARGET_USER kvm

#Enable The virtualization daemon
systemctl enable --now libvirtd

#install Virt-Mgt
apt install -y virt-manager

#Make Creat the VNC config
cat > /etc/network/interfaces <<EOF
#!/bin/sh
#create VLAN
auto $IF_NAME.$VLAN_ID
iface $IF_NAME.$VLAN_ID inet static
EOF

#Load the VLAN
systemctl restart networking.service

exit
