#!/bin/sh

# The userid and password for who will run VNC
read -p "Please enter the UserID for VNC: " TARGET_USER
read -p "Please enter the Password for $TARGET_USER: " TARGET_USER_PASSWORD

#Interface Name
IF_NAME="bond0"

# Ask user for the VLAN ID
read -p "Please enter the VLAN ID for $IF_NAME: " VLAN_ID

# Ensure the VLAN ID is provided
if [ -z "$VLAN_ID" ]; then
    echo "VLAN ID is required. Exiting."
    exit 1
fi

#Create VNCUser and set password
useradd -m $TARGET_USER && echo "${TARGET_USER}:${TARGET_USER_PASSWORD}" | chpasswd

## Install VNC
#run update
apt -y upgrade
apt -y update

#Install TigerVNC   ** Not tightvnc **
apt -y install tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer
apt -y install ubuntu-gnome-desktop gnome-session gnome-terminal
#systemctl enable gdm
#systemctl start gdm

#set VNC Env
mkdir -p /home/$TARGET_USER/.vnc
chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.vnc

#Create the VNC config
cat > /home/$TARGET_USER/.vnc/xstartup <<EOF
#!/bin/sh
/usr/bin/gnome-session
EOF

chmod +x /home/$TARGET_USER/.vnc/xstartup

#open the ports
echo "Opening FW Ports"
ufw allow 5901/tcp
#ufw allow 5902/tcp
ufw reload

### install VirtMgr

#Just to be sure
apk add bash curl jq openssl sudo nano git pciutils gzip p7zip cpio tar unzip xarchiver ethtool
apt -y install qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
apt -y update

#Allow the user access to KVM
adduser $TARGET_USER libvirt
adduser $TARGET_USER kvm

#Enable The virtualization daemon
systemctl enable --now libvirtd

#install Virt-Mgt
apt install -y virt-manager

#Make Creat the VLAN config
cat > /etc/network/interfaces <<EOF
#!/bin/sh
#create VLAN
auto $IF_NAME.$VLAN_ID
iface $IF_NAME.$VLAN_ID inet static
EOF

#Load the VLAN
systemctl restart networking.service

#print public IP address
PUBLIC_IP=$(curl -s https://metadata.platformequinix.com/metadata | jq -r ".network.addresses[] | select(.public == true) | select(.address_family == 4) | .address")
echo "Public IP is : $PUBLIC_IP"

#Do not Start the VNCServer, in the script
echo "Please start VNC manually and set the VNCPassword"
echo "su - $TARGET_USER"
echo "vncserver"
echo ""

#Please reboot when finished
echo "Also please reboot your server when you have finished the config"

exit
