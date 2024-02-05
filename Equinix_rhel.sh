#!/bin/sh

# The username for whom to set the VNC password
TARGET_USER="vncuser1"
TARGET_USER_PASSWORD="admin"

# The desired password
VNC_PASSWORD="snaresnare"

# Create a temporary script to set the VNC password
TMP_SCRIPT=$(mktemp)

yum -y install tigervnc-server tigervnc
yum -y group install GNOME base-x
yum -y groupinstall "Server with GUI"
systemctl set-default graphical.target
systemctl isolate graphical.target

#Create the User Env
useradd -m $TARGET_USER && echo '$TARGET_USER:$TARGET_USER_PASSWORD' | sudo chpasswd

#set VNC Env
mkdir -p /home/$TARGET_USER/.vnc
chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.vnc
touch /home/$TARGET_USER/.vnc/config
echo 'session=gnome' > /home/$TARGET_USER/.vnc/config
echo ':1=$TARGET_USER' >> /etc/tigervnc/vncserver.users
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service

# Create a temporary script to set the VNC password
TMP_SCRIPT=$(mktemp)

echo "#!/bin/bash
echo \$VNC_PASSWORD | vncpasswd" > "$TMP_SCRIPT"

# Make the temporary script executable
chmod +x "$TMP_SCRIPT"

# Execute the script as the target user
sudo -u "$TARGET_USER" VNC_PASSWORD="$VNC_PASSWORD" "$TMP_SCRIPT"

# Remove the temporary script
rm "$TMP_SCRIPT"

#open the ports
firewall-cmd --permanent --zone=public --add-port 5901/tcp
firewall-cmd  --reload





