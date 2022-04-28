### Note:
If you are provider only 1 server or you already have kubernetes then use [praetorapp.com](https://praetorapp.com) to become provider


## Step 1 - Install Kubernetes

Prerequisits

- Have 3 or 4 server either running in cloud or in local PC using virtualization (e.g VirtualBox)
- Install supported OS (Debain 11, Debian 10, Centos 7, Ubuntu 20)
- Make sure you have open root access to all servers by following [Root Access](https://github.com/PraetorOne/kube-sh/blob/main/guides/ROOTACCESS.md) guide
- Have all servers in same network aka local network and enter only local ip address when running first script

Run this script in seperate control machine which is not part of Kubernetes setup

```shell
wget https://raw.githubusercontent.com/PraetorOne/kube-sh/main/kube.sh
chmod +x kube.sh
./kube.sh
```

## Step 2 - Download Kube config file from Master Node

When you finish running above script without error, It is time to download kube config file from master node of the Kubernetes.

To access Kubernetes from anywhere, you need to edit config file and add insecure-skip-tls-verify: true. Warning: Editing this create insecure environment. We not recommend this step.

If your control machine is in same local network and it can access kubernetes from control machine then you can skip this part.

```yaml
apiVersion: v1
clusters:
  - cluster:
      insecure-skip-tls-verify: true # Add this line in the config file
```

And remove certificate from config file.

## Step 3 - Use Praetor App to become Provider

Go to [praetorapp.com](https://praetorapp.com) to become provider and follow the on screen instruction.

Note: when asked is this kubernetes akash Ready? Then Say **NO** , Praetor will install required dependencies.

## Issues

Please create an issue in this repo if you find any in these scripts.
