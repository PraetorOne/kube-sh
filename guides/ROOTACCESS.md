# Enable Root Access

To enable root access to your debian, ubuntu or cent os, we need to edit sshd_config file in /etc/ssh directory and restart the server

Warning! Enabling this have serious cosequences, Please disable root access after installing kubernetes.

#### Edit sshd_config file

```shell
cd /etc/ssh

# you can also use vi to edit this file
nano /etc/sshd_config

# add this lines in bottom of file
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
```

#### Restart SSH server

```shell
service sshd restart
# or systemctl restart sshd
```

#### Add Password to Root Access

```shell
# if you are in root then skip this step
sudo su

# Add password to root user
passwd
```

Make sure you have 22 port open for public

#### Warning! Remove added lines after kubernetes installation
