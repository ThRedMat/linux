sudo yum update -y
sudo yum install wget git nano mariadb-server nfs-utils -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
# PARTIE MYSQL
mysql -u root -e "SET old_passwords=0;
CREATE USER 'gitea'@'192.168.56.11' IDENTIFIED BY '';
CREATE DATABASE giteadb CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci';
GRANT ALL PRIVILEGES ON *.* TO 'gitea'@'192.168.56.11' WITH GRANT OPTION;
FLUSH PRIVILEGES;"

#NFS
mkdir /mnt/nfsfileshare
mount 192.168.56.14:/nfsfileshare /mnt/nfsfileshare

# HOSTS
sudo echo "192.168.56.11  node1.tp4.gitea node1gitea" >> /etc/hosts
sudo echo "192.168.56.13  node3.tp4.nginx node3nginx" >> /etc/hosts
sudo echo "192.168.56.14  node4.tp4.nfs node4nfs" >> /etc/hosts