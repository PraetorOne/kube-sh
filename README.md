## Step 1 - Install Kubernetes

Prerequisits

- Have 3 or 4 server either running in cloud or in local PC using virtualization (e.g VirtualBox)
- Install supported OS (Debain 11, Debian 10, Centos 7, Ubuntu 20)
- Make sure you have open root access to all servers by following this guide
- Have all servers in same network aka local network and enter only local ip address when running first script

Run this script in seperate control machine which is not part of Kubernetes setup

```shell
curl https://github.com/PraetorOne/kube-sh/blob/main/kube.sh
chmod +x kube.sh
kube.sh
```

## Step 2 - Download Kube config file from Master Node

When you finish running above script without error, It is time to download kube config file from master node of the Kubernetes.

Copy file from Kubernetes Master node

```shell
mkdir ~/.kube
scp root@{MasterNodeIp}:/etc/kubernetes/admin.conf ~/.kube/config
```

To access Kubernetes from anywhere, you need to edit config file and add insecure-skip-tls-verify: true. Warning: Editing this create insecure environment. We not recommend this step.

If your control machine is in same local network and it can access kubernetes from control machine then you can skip this part.

```yaml
apiVersion: v1
clusters:
  - cluster:
      insecure-skip-tls-verify: true # Add this line in the config file
```

## Step 3 - Ready Kubernetes cluster for Akash

```shell
curl https://github.com/PraetorOne/kube-sh/blob/main/akash.sh
chmod +x akash.sh
akash.sh
```

After this step check if everything is install using following script and check result

Check if kubernetes server can be accessed through control machine.

```shell
kubectl get nodes

# Result
# node1   Ready    control-plane,master   4d20h   v1.23.4
# node2   Ready    control-plane,master   4d20h   v1.23.4
# node3   Ready    <none>                 4d20h   v1.23.4
# node4   Ready    <none>                 4d20h   v1.23.4
```

```shell
kubectl get networkpolicy

# Result
# default-deny-ingress   <none>         4d20h
```

```shell
kubectl get crd

# Confirm this entries in the list
# manifests.akash.network
# providerhosts.akash.network
```

## Step 4 - Become Akash Provider using Praetor Provider service

Go to [Praetor Provider](https://praetor.testcoders.com) and connect wallet to get started.

### Issues

Please create an issue in this repo if you find any in these scripts.
