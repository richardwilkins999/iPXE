#!/bin/sh

# The username for whom to set the VNC password
TARGET_USER="vncuser1"
TARGET_USER_PASSWORD="snaresnare"

#Create VNCUser and set password
useradd -m $TARGET_USER && echo "${TARGET_USER}:${TARGET_USER_PASSWORD}" | chpasswd

#run update
apt -y upgrade
apt -y update

#Install TigerVNC   ** Not tightvnc **
apk add bash curl jq openssl sudo nano git pciutils gzip p7zip cpio tar unzip xarchiver ethtool
apt install -y tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer
#apt install -y xfce4 xfce4-goodies
apt install -y ubuntu-gnome-desktop gnome-session gnome-terminal
#systemctl enable gdm
#systemctl start gdm

#set VNC Env
mkdir -p /home/$TARGET_USER/.vnc
chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.vnc

#Make Creat the VNC config
cat > /home/$TARGET_USER/.vnc/xstartup <<EOF
#!/bin/sh
/usr/bin/gnome-session
EOF

chmod +x /home/$TARGET_USER/.vnc/xstartup

#run update again  ?:-)
apt -y update

#open the ports
echo "Opening FW Ports"
ufw allow 5901/tcp
ufw allow 5902/tcp
ufw reload

#Do not Start the VNCServer, in the script
echo "Please start VNC manually and set the VNCPassword"
echo "su - $TARGET_USER"
echo "vncserver"


#print public IP address
PUBLIC_IP=$(curl -s https://metadata.platformequinix.com/metadata | jq -r ".network.addresses[] | select(.public == true) | select(.address_family == 4) | .address")
echo "Public IP is : $PUBLIC_IP"

echo "please reboot your server"
