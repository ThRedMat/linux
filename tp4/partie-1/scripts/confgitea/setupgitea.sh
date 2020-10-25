#!/bin/bash

# DARRIBAU Mathieu
# 23/10/2020
# script setup gitea

wget -O gitea https://dl.gitea.io/gitea/1.12.5/gitea-1.12.5-linux-amd64
chmod +x gitea

useradd git -m -s /bin/bash

mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea

cp gitea /usr/local/bin/gitea

chmod 750 /etc/gitea

chmod 640 /etc/gitea/app.ini


systemctl enable gitea.service
systemctl start gitea.service

GITEA_WORK_DIR=/var/lib/gitea/ /usr/local/bin/gitea web -c /etc/gitea/app.ini