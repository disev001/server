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
systemctl enable docker.service
systemctl enable containerd.service
groupadd docker
usermod -aG docker $SUDO_USER
mkdir -p /home/$SUDO_USER/.docker
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.docker -R
chmod g+rwx /home/$SUDO_USER/.docker -R

#install kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl
systemctl start docker
newgrp docker
docker ps

#aufrufbar über curl -s https://raw.githubusercontent.com/disev001/server/master/setup.sh | bash
#oder download curl https://raw.githubusercontent.com/disev001/server/master/setup.sh >> filename.sh