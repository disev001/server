#!/bin/bash
path=$(pwd)
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"
echo "Root granted for $SUDO_USER. Setting up kubernetes for docker (k3d)"
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

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

k3d cluster create devops -p "8081:80@loadbalancer" --agents 2
echo "0#k3d cluster created"
kubectl create namespace devops
echo "1#kubectl create namespace"
kubectl apply -f ./serviceAccount.yaml
echo "2#kubectl create serviceAccount"
kubectl create -f ./volume.yaml
echo "3#kubectl create volume"
kubectl apply -f ./deployment.yaml
echo "4#kubectl apply deployment"
kubectl get deployments -n devops
echo "5#kubectl describe deployment"
kubectl describe deployments --namespace=devops
#echo "6#kubectl apply service"
kubectl apply -f ./service.yaml

sudo firewall-cmd --zone=public --permanent --add-port 8085/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports