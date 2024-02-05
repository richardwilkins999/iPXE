#!/bin/sh


# The username for whom to set the VNC password
TARGET_USER="vncuser1"
TARGET_USER_PASSWORD="snaresnare"

#Create VNCUser
useradd -m $TARGET_USER && echo '$TARGET_USER:$TARGET_USER_PASSWORD' | chpasswd

#Install TigerVNC   ** Not tightvnc **
apt install tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer
apt install ubuntu-gnome-desktop
systemctl enable gdm
systemctl start gdm

#set VNC Env
mkdir -p /home/$TARGET_USER/.vnc
chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.vnc

#Make Creat the VNC config
cat > /home/$TARGET_USER/.vnc/xstartup <<EOF
#!/bin/sh
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="GNOME-Flashback:GNOME"
export XDG_MENU_PREFIX="gnome-flashback-"
gnome-session --session=gnome-flashback-metacity --disable-acceleration-check &
EOF


#open the ports
echo "Opening FW Ports"
ufw allow 5901/tcp

#Do not Start the VNCServer, in the script
echo "Please start VNC manually and set the VNCPassword"
echo "su - $TARGET_USER"
echo "vncserver"
