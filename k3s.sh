#!/bin/bash

# Follow guide at https://github.com/PraetorOne/K3s-sh

function apt_depends() {
    apt-get update && apt-get upgrade -y
    apt-get install git -y
}

function yum_depends() {
    yum update -y
    yum install epel-release
    yum install -y git
}

OS_RELEASE=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
CENT_OS='"CentOS Linux"'
DEBIAN='"Debian GNU/Linux"'
UBUNTU='"Ubuntu"'

if [ "$UBUNTU" = "$OS_RELEASE" ]; then
    apt_depends
elif [ "$CENT_OS" = "$OS_RELEASE" ]; then
    yum_depends
elif [ "$DEBIAN" = "$OS_RELEASE" ]; then
    apt_depends
fi


# Run K3S
curl -sfL https://get.k3s.io | sh -s - --node-name node1
alias kubectl='k3s kubectl'

sleep 30

kubectl get nodes

# Copy config file
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config