#!/bin/bash

# Follow guide at https://github.com/PraetorOne/kube-sh

function apt_depends() {
    apt-get update
    apt-get install -y python3-pip git sshpass software-properties-common unzip
    add-apt-repository --yes --update ppa:ansible/ansible
    # apt-get install -y ansible
    apt install libffi-dev
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    git clone https://github.com/kubernetes-sigs/kubespray.git
    cd kubespray
    pip3 install -r requirements.txt
}

function yum_depends() {
    yum update
    yum install epel-release
    yum install -y python3-pip git sshpass software-properties-common libffi libffi-devel unzip
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    git clone https://github.com/kubernetes-sigs/kubespray.git
    cd kubespray
    pip3 install -r requirements.txt
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

echo "Please enter username"
read USER

# echo "Please enter password of all nodes"
# read pass

# export SSHPASS=$pass

echo "How many nodes are your connecting?"
read NODECOUNT

# echo "Please enter Node IP Separated by space"
# read -a IPS

ssh-keygen -t rsa -C $(hostname) -f "$HOME/.ssh/id_rsa" -P ""
cat ~/.ssh/id_rsa.pub

#Assign static IP to your Kubernetes Hosts and update the user and IP address below
declare -a IPS
for i in $(seq $NODECOUNT); do
    echo "Please enter Node ${i} ip address"
    read dest

    if [ $i = 1 ]; do
    export MASTERNODEIP=${dest}

    echo "Please enter password ${dest}"
    read pass

    export SSHPASS=$pass

    IPS+=" ${dest}"
    ssh-keyscan -H $dest >>~/.ssh/known_hosts
    sshpass -e ssh-copy-id -i ~/.ssh/id_rsa.pub $USER@$dest
    unset SSHPASS
done

echo "using nodes ${IPS}..."

function ansible() {
    #Setup ansible
    cp -rfp inventory/sample inventory/akash
    #Create config.yaml
    CONFIG_FILE=inventory/akash/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
    cat inventory/akash/hosts.yaml
    #Enable gvisor for security
    ex inventory/akash/hosts.yaml <<eof
2 insert
  vars:
    cluster_id: "1.0.0.1"
    ansible_user: root
    gvisor_enabled: true
.
xit
eof
    echo "File Modified"
    cat inventory/akash/hosts.yaml
}
ansible

#Run Kubespray
ansible-playbook -i inventory/akash/hosts.yaml -b -v --private-key=~/.ssh/id_rsa cluster.yml

# Export kube config
mkdir ~/.kube
scp root@${MASTERNODEIP}:/etc/kubernetes/admin.conf ~/.kube/config

stable=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO https://storage.googleapis.com/kubernetes-release/release/${stable}/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl