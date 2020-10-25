#!/bin/bash

# DARRIBAU Mathieu
# 25/10/2020
# script d'installation pour node3

yum install epel-release -y
yum install nginx -y

systemctl enable nginx
systemctl start nginx

