#!/bin/bash

# DARRIBAU Mathieu
# 04/10/2020
# script conf node1 

# ajout des zones publics pour les services http et https
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

# ajout de l'user admin 
useradd admin -m
usermod -aG wheel admin

# ajout de l'user web pour nginx
useradd web -M -s /sbin/nologin

# ajout de l'user backup
useradd backup -M

# creation du certificat 
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
	-keyout /etc/pki/tls/private/server.key \
	-out /etc/pki/tls/certs/server.crt \
	-subj "/C=/ST=/L=/O=/OU=/CN=node1.tp2.b2"

chmod 400 /etc/pki/tls/private/server.key
chown web:web /etc/pki/tls/private/server.key
chown web:web /etc/pki/tls/certs/server.crt
chmod 444 /etc/pki/tls/certs/server.crt

# start nginx
systemctl enable nginx
systemctl start nginx

mkdir /srv/site1/
touch /srv/site1/index.html
echo '<h1>Hello from site 1</h1>' | tee /srv/site1/index.html

mkdir /srv/site2/
touch /srv/site2/index.html
echo '<h1>Hello from site 2</h1>' | tee /srv/site2/index.html

chown web:web /srv/site1 -R
chmod 700 /srv/site1 /srv/site2
chmod 400 /srv/site1/index.html /srv/site2/index.html
