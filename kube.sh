#!/bin/bash
#This bootstrap makes some assumptions:
#1 : 3 new bare-metal servers using Debian 11 with root user and ssh password login enabled.
#2 : A control machine to run this bootstrap from and control your new cluster.  The control machine needs all the dependencies in the depends function.
#3 : Update USER, SSHPASS, NODE1, NODE2, NODE3 with your servers info.  You can add as many nodes as you like, just use the same format. "export NODEX=x.x.x.x"

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

export OS_RELEASE=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
export CENT_OS='"CentOS Linux"'
export DEBIAN='"Debian GNU/Linux"'
export UBUNTU='"Ubuntu"'

if [ "$CENT_OS" = "$OS_RELEASE" ]; then
    yum_depends
elif [ "$DEBIAN" = "$OS_RELEASE"]; then
    apt_depends
elif [ "$UBUNTU" = "$OS_RELEASE"]; then
    apt_depends
fi

###Server settings
# USER=root #user on nodes to use
# export SSHPASS=chilblaain #password to use to sync ssh keys
# export NODE1=3.99.170.165 #node IP
# export NODE2=3.98.139.185 #node IP
# export NODE3=35.183.22.64 #node IP
####

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

#Run Helm
export KUBECONFIG=$KUBECONFIG
