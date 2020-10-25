#!/bin/bash

# DARRIBAU Mathieu
# 25/10/2020
# script d'installation de node4


sudo yum update -y
sudo yum install wget git nano epel-release nfs-utils -y
systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service mountd
sudo firewall-cmd --permanent --add-service rpc-bind
sudo firewall-cmd --permanent --add-service nfs
sudo firewall-cmd --reload
sed -i '/#Domain = local.domain.edu/c\Domain = node4.tp4.nfs' /etc/idmapd.conf
sudo mkdir /nfsfileshare
chmod 777 /nfsfileshare

# NFS
echo -e "/nfsfileshare   192.168.56.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsfileshare   192.168.56.12(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsfileshare   192.168.56.13(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
" > /etc/exports
exportfs -r
systemctl restart nfs-server

# HOSTS
sudo echo "192.168.56.11  node1.tp4.gitea node1gitea" >> /etc/hosts
sudo echo "192.168.56.12  node2.tp4.bdd node2bdd" >> /etc/hosts
sudo echo "192.168.56.13  node3.tp4.nginx node3nginx" >> /etc/hosts