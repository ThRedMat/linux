# TP 1 Déploiement classique

## 0. Prérequis

Tout d'abord on créé un disque SATA de 5 Go avant de le partitionner via LVM.

On lance la vm pour ensuite se connecter en SSH :

```
PS C:\Users\Mathieu> ssh dmathieu@192.168.1.11
dmathieu@192.168.1.11's password:
Last login: Wed Sep 23 16:04:25 2020
Last login: Wed Sep 23 16:04:25 2020
[dmathieu@localhost ~]$
```

Une fois cette étape faite, on va installer LVM :

```
[dmathieu@localhost ~]$ sudo yum install lvm
[sudo] Mot de passe de dmathieu : 
Modules complémentaires chargés : fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.mirrors.proxad.net
 * epel: mirror.nl.leaseweb.net
 * extras: centos.mirrors.proxad.net
 * updates: centos.quelquesmots.fr
Aucun paquet lvm disponible.
Erreur : Rien à faire
[dmathieu@localhost ~]$
```

Donc notre paquet LVM est bien installé.

Maintenant que l'on a crée le disque sur notre vm, on va partitionner le disque en utilisant les lignes de commande suivante :

```
[dmathieu@localhost ~]$ sudo lvcreate -L 2000 data -n vol1
  Logical volume "vol1" created.
[dmathieu@localhost ~]$ sudo lvcreate -L 3000 data -n vol2
  Logical volume "vol2" created.
[dmathieu@localhost ~]$ sudo lvs
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root centos -wi-ao----  <6,20g
  swap centos -wi-ao---- 820,00m
  vol1 data   -wi-a-----   1,95g
  vol2 data   -wi-a-----  <2,93g
[dmathieu@localhost ~]$ sudo lvscan
  ACTIVE            '/dev/centos/swap' [820,00 MiB] inherit
  ACTIVE            '/dev/centos/root' [<6,20 GiB] inherit
  ACTIVE            '/dev/data/vol1' [1,95 GiB] inherit
  ACTIVE            '/dev/data/vol2' [<2,93 GiB] inherit

```

Une fois cette étape réalisée on va monter les partitions dans des dossiers appelés site 1 et site 2 :

```

[dmathieu@localhost srv]\$ sudo mkfs -t ext4 /dev/data/vol1
mke2fs 1.42.9 (28-Dec-2013)
Ne peut évaluer par stat() /dev/data/vol1 --- Aucun fichier ou dossier de ce type

Le périphérique n'existe apparemment pas ; l'avez-vous spécifié
correctement ?
[dmathieu@localhost srv]\$ sudo mkfs -t ext4 /dev/data/volume2
mke2fs 1.42.9 (28-Dec-2013)
Étiquette de système de fichiers=
Type de système d'exploitation : Linux
Taille de bloc=4096 (log=2)
Taille de fragment=4096 (log=2)
« Stride » = 0 blocs, « Stripe width » = 0 blocs
192000 i-noeuds, 768000 blocs
38400 blocs (5.00%) réservés pour le super utilisateur
Premier bloc de données=0
Nombre maximum de blocs du système de fichiers=786432000
24 groupes de blocs
32768 blocs par groupe, 32768 fragments par groupe
8000 i-noeuds par groupe
Superblocs de secours stockés sur les blocs :
32768, 98304, 163840, 229376, 294912

Allocation des tables de groupe : complété
Écriture des tables d'i-noeuds : complété
Création du journal (16384 blocs) : complété
Écriture des superblocs et de l'information de comptabilité du système de
fichiers : complété

[dmathieu@localhost srv]$ sudo mount /dev/data/vol1 /srv/site1
[dmathieu@localhost srv]$ sudo mount /dev/data/vol2 /srv/site2

```

Ensuite on monte les partitions dans fstab:

```

[dmathieu@localhost ~]$ sudo mount -av
/                         : ignoré
/boot                     : déjà monté
swap                      : ignoré
/srv/site1                : déjà monté
/srv/site2                : déjà monté
[dmathieu@localhost ~]$

```

Puis on modifie le fichier fstab en rajoutant les deux lignes suivantes :

```

[dmathieu@localhost srv]\$ sudo nano /etc/fstab
/dev/data/vol1 /srv/site1 ext4 defaults 0 0
/dev/data/vol2 /srv/site2 ext4 defaults 0 0

```

Maintenant on va tester si notre vm a bien accès a internet

On change le nom de nos vm avec la commande `sudo nano /etc/hostname`

```
[dmathieu@node1 ~]$ hostname
node1.tp1.b2
```

et pour la seconde vm

```
[dmathieu@node2 ~]$ hostname
node2.tp1.b2
```

```
[dmathieu@node1 ~]$ sudo nmcli dev
DEVICE  TYPE      STATE     CONNECTION
enp0s3  ethernet  connecté  enp0s3
enp0s8  ethernet  connecté  enp0s8
lo      loopback  non-géré  --
[dmathieu@node1 ~]$
```

Ensuite on fait un curl de google.com

```
[dmathieu@node1 ~]$ sudo curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
[dmathieu@node1 ~]$
```

Donc nous avons bien accès à internet.

On essaye de ping nos vm entre elles:

node1.tp1.b2 vers node2.tp1.b2

```
[dmathieu@node1 ~]$ ping 192.168.1.12
PING 192.168.1.12 (192.168.1.12) 56(84) bytes of data.
64 bytes from 192.168.1.12: icmp_seq=1 ttl=64 time=0.560 ms
64 bytes from 192.168.1.12: icmp_seq=2 ttl=64 time=0.372 ms
64 bytes from 192.168.1.12: icmp_seq=3 ttl=64 time=0.373 ms
64 bytes from 192.168.1.12: icmp_seq=4 ttl=64 time=0.349 ms
```

et node2.tp1.b2 vers node1.tp1.b2

```
[dmathieu@node2 ~]$ ping 192.168.1.11
PING 192.168.1.11 (192.168.1.11) 56(84) bytes of data.
64 bytes from 192.168.1.11: icmp_seq=1 ttl=64 time=0.330 ms
64 bytes from 192.168.1.11: icmp_seq=2 ttl=64 time=0.366 ms
64 bytes from 192.168.1.11: icmp_seq=3 ttl=64 time=0.353 ms
64 bytes from 192.168.1.11: icmp_seq=4 ttl=64 time=0.353 ms
^C
--- 192.168.1.11 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3007ms
rtt min/avg/max/mdev = 0.330/0.350/0.366/0.022 ms
```

on remplace par node1.tp1.b2 et node2.tp1.b2

```
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.11 node1.tp1.b2
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.12 node2.tp1.b2
```

puis reboot les 2 vm's pour effectuer le changement

on peut voir via la commande hostname que la premiere vm a bien changé de nom

```
[dmathieu@node1 ~]\$ hostname
node1.tp1.b2
pour la deuxieme vm
```

```
[dmathieu@node2 ~]\$ hostname
node2.tp1.b2
```

maintenant nous devons ping les vms via leur noms respectif

nous devons ajouter dans le fichier `/etc/hosts` l'adresse ip et le nom de notre vm qui node2.tp1.b2

ce qui donne

```
[dmathieu@node1 tmp]$ ping node1.tp1.b2
PING node1.tp1.b2 (10.0.2.15) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (10.0.2.15): icmp_seq=1 ttl=64 time=0.010 ms
64 bytes from node1.tp1.b2 (10.0.2.15): icmp_seq=2 ttl=64 time=0.018 ms
^C
--- node1.tp1.b2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 0.010/0.014/0.018/0.004 ms
[dmathieu@node1 tmp]$
```

et on fait la meme via notre seconde vm

```
[dmathieu@node2 ~]\$ ping node1.tp1.b2
PING node1.tp1.b2 (192.168.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=0.356 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=0.349 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=3 ttl=64 time=0.254 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=4 ttl=64 time=0.309 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=5 ttl=64 time=0.293 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=6 ttl=64 time=0.289 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=7 ttl=64 time=0.309 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=8 ttl=64 time=0.286 ms
^C
--- node1.tp1.b2 ping statistics ---
8 packets transmitted, 8 received, 0% packet loss, time 7006ms
rtt min/avg/max/mdev = 0.254/0.305/0.356/0.037 ms

[mathieu@node2 ~]\$ ping node1.tp1.b2
PING node1.tp1.b2 (192.168.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=0.252 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=0.285 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=3 ttl=64 time=0.313 ms
^C
--- node1.tp1.b2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.252/0.283/0.313/0.028 ms

```

Donc on peut ping nos vm entre elles.

Creation de nouveau user avec les droit sudo

```
[dmathieu@node2 ~]$ useradd siteweb
[dmathieu@node2 ~]$ sudo visudo
puis edit les droit sudo en donnant les droits sudo
```

```
Allow Mathieu to run any commands anywhere
%wheel ALL=(ALL) ALL
siteweb ALL=(ALL) ALL
sur les deux vm's
```

- Utilisation que de ssh
  vous n'utilisez QUE ssh pour administrer les machines

création d'une paire de clés (sur VOTRE PC)

```
PS C:\Users\Mathieu\.ssh> cat .\known_hosts
192.168.1.11 ecdsa-sha2-nistp256 [...]=
192.168.1.12 ecdsa-sha2-nistp256 [...]=
déposer la clé sur l'utilisateur
```

Machine 1

```
PS C:\Users\Mathieu> ssh dmathieu@192.168.1.11
admin1@192.168.1.11's password:
Last login: Thu Sep 24 14:10:21 2020 from 192.168.1.10
Last login: Thu Sep 24 14:10:21 2020 from 192.168.1.10
[dmathieu@node1 ~]$
```

Machine 2

```
PS C:\Users\Mathieu> ssh dmathieu@192.168.1.12
dmathieu@192.168.1.12's password:
Last login: Thu Sep 24 15:09:52 2020 from 192.168.1.10
Last login: Thu Sep 24 15:09:52 2020 from 192.168.1.10
[dmathieu@node2 ~]$
```

### Firewall

le pare-feu est configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires

commande firewall-cmd ou iptables

Machine 1

```
[dmathieu@node1 ~]$ sudo firewall-cmd --list-all
sudo firewall-cmd --list-all
public (active)
target: default
icmp-block-inversion: no
interfaces: enp0s3 enp0s8
sources:
adminices: dhcpv6-client ssh
ports:
protocols:
masquerade: no
forward-ports:
source-ports:
icmp-blocks:
rich rules:
[dmathieu@node1 ~]\$
```

Machine 2

```
[dmathieu@node2 ~]$ sudo firewall-cmd --list-all
[sudo] password for dmathieu:
public (active)
target: default
icmp-block-inversion: no
interfaces: enp0s3 enp0s8
sources:
adminices: dhcpv6-client ssh
ports:
protocols:
masquerade: no
forward-ports:
source-ports:
icmp-blocks:
rich rules:
[dmathieu@node2 ~]\$
```

désactiver SELinux

Machine 1

```
[dmathieu@node1 ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux bapti directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
[dmathieu@node1 ~]$
```

Machine 2

```
[dmathieu@node2 ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux bapti directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
[dmathieu@node2 ~]$
```

## I. Setup serveur Web

### Install de nginx sous Centos7

Pour installer NGINX, on doit d'abord installer le package `epel-release` avec la commande `sudo yum install epel-release`

```
[dmathieu@node1 ~]$ sudo yum install epel-release
```

Une fois fait, on peut installer nginx avec la commande `sudo yum install -y nginx`

```
[dmathieu@node1 ~]$ sudo yum install -y nginx
```

### Créations des fichiers index.html

Dans le dossier site1

```
[dmathieu@node1 ~]$ cd /srv/site1
[dmathieu@node1 site1]$ sudo touch index.html
[dmathieu@node1 site1]$ ls
index.html
```

Dans le dossier site2

```
[dmathieu@node1 ~]$ cd /srv/site2
[dmathieu@node1 site2]$ sudo touch index.html
[dmathieu@node1 site2]$ ls
index.html
[dmathieu@node1 site2]$
```

## Configuration de NGINX

- les permissions sur ces dossiers doivent être le plus restrictif possible et, ces dossiers doivent appartenir à un utilisateur et un groupe spécifique

```
[dmathieu@node1 ~]$ sudo ls -al /srv/
total 8
drwxr-xr-x.  4 root root   32 Sep 23 17:31 .
dr-xr-xr-x. 17 root root  237 Sep 22 14:21 ..
dr--------.  3 web  web  4096 Sep 26 15:39 site1
dr--------.  3 web  web  4096 Sep 26 15:39 site2
[dmathieu@node1 ~]
```

- NGINX doit utiliser un utilisateur dédié que vous avez créé à cet effet

```
[dmathieu@node1 ~]$ sudo useradd siteweb
```

- les sites doivent être servis en HTTPS sur le port 443 et en HTTP sur le port 80

```
[dmathieu@node1 ~]$ sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
success

[dmathieu@node1 ~]$ sudo firewall-cmd --permanent --zone=public --add-service=https
success

[dmathieu@node1 ~]$ sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
success

[dmathieu@node1 ~]$ sudo firewall-cmd --permanent --zone=public --add-service=http
success

[dmathieu@node1 ~]$ sudo firewall-cmd --reload
success
[dmathieu@node1 ~]$
```

- Prouver que la machine node2 peut joindre les deux sites web.

Site 1

```
[dmathieu@node2 ~]\$ curl -Lk http://node1.tp1.b2/site1

<!doctype html>
<html lang="en">
<head>
        <meta charset="utf-8">
        <title>Dummy Page</title>
        [...]
</head>

<body>
        <div class="pure-g">
                <div class="pure-u-1">
                        <h1>Stay tuned site 1 <h1>
                        <h2>something new is coming here</h2>
                        [...]
                </div>
        </div>
</body>
<script>
[...]
</script>
</html>
[dmathieu@node2 ~]$
```

Site 2

```
[dmathieu@node2 ~]\$ curl -Lk http://node1.tp1.b2/site2


<!doctype html>
<html lang="en">
<head>
        <meta charset="utf-8">
        <title>Dummy Page</title>
        [...]
</head>

<body>
        <div class="pure-g">
                <div class="pure-u-1">
                        <h1>Stay tuned site 2 <h1>
                        <h2>something new is coming here</h2>
                        [...]
                </div>
        </div>
</body>
<script>
[...]
</script>
</html>
[dmathieu@node2 ~]$
```

## II.Script de sauvegarde

```
#!/bin/bash

# DARRIBAU Mathieu
# 27/09/2020
# Backup script

backup_time=$(date +%Y%m%d_%H%M)

saved_folder_path="${1}"

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

tar -czf $backup_name.tar.gz --absolute-names $saved_folder_path

nbr_site1=`ls -l | grep -c site1_`
nbr_site2=`ls -l | grep -c site2_`

echo $nbr_site1
echo $nbr_site2

if [ "$nbr_site1" > 7 ]; then
        echo "ça fonctionne très bien"

fi
```

## III.Monitoring

Installation :

```
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

```
tester firewall-cmd --add-port=19999/tcp --permanent firewall-cmd --reload
```

Pour pour ce qui est de l'envoi de messages sur discord

On lui crée un salon dédié puis on crée un webhook pour y copié le lien puis l'ajouter a notre conf netdata

```
[dmathieu@node1 ~]$ cat /etc/netdata/health_alarm_notify.conf
https://discordapp.com/api/webhooks/760166157487046696/KV_uChPKmhRNrsCwAmyXL-xWRztM7295hj7goYYdAtVpcjb9I83K_ig9hCxztxMzPbYJ
[dmathieu@node1 ~]$
```
