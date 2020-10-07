#!/bin/sh

# DARRIBAU Mathieu
# 07/10/2020


yum update -y
yum install -y epel-release
yum install -y nginx
yum install -y vim

setenforce 0
echo "SELINUX=permissive\nSELINUXTYPE=targeted" > /etc/selinux/config

systemctl enable firewalld
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload