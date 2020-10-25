#!/bin/bash

# DARRIBAU Mathieu
# 15/10/2020
# script d'installation

yum update -y

setenforce 0
sed -i 's/.*SELINUX=enforcing.*/SELINUX=permissive/' /etc/selinux/config

yum install vim -y
yum install tree -y