#!/bin/bash
#Check Sudo
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"
echo "Root granted for $SUDO_USER. Setting up Docker for Fedora"
#install updates & docker
dnf update -y && dnf upgrade -y
dnf install -y nano dnf-plugins-core
dnf config-manager -y --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf update -y
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
#setup docker for user
groupadd -f docker
usermod -aG docker $SUDO_USER
mkdir -p /home/$SUDO_USER/.docker
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.docker -R
chmod g+rwx /home/$SUDO_USER/.docker -R
systemctl start docker
systemctl enable docker.service
systemctl enable containerd.service
while true; do
    read -p "Do you wish to restart to apply the settings? " yn
    case $yn in
        [Yy]* ) sudo reboot; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
exit
#aufrufbar über: curl -s https://raw.githubusercontent.com/disev001/server/master/setup.sh | bash
#oder download: curl https://raw.githubusercontent.com/disev001/server/master/setup.sh >> filename.sh
#Installation per lokalen ssh aufruf: curl -s https://raw.githubusercontent.com/disev001/server/master/setup.sh | ssh disev@192.168.178.43 'bash -s