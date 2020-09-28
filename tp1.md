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

Donc on peut ping nos vm entre elles.

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

## I. Setup serveur Web

Pour installer NGINX, on doit d'abord installer le package `epel-release` avec la commande `sudo yum install epel-release`

```
[dmathieu@node1 ~]$ sudo yum install epel-release
Modules complémentaires chargés : fastestmirror
Loading mirror speeds from cached hostfile
epel/x86_64/metalink                                                                             |  18 kB  00:00:00
 * base: centos.mirrors.proxad.net
 * epel: mirror.nl.leaseweb.net
 * extras: centos.mirrors.proxad.net
 * updates: centos.quelquesmots.fr
base                                                                                             | 3.6 kB  00:00:00
epel                                                                                             | 4.7 kB  00:00:00
extras                                                                                           | 2.9 kB  00:00:00
updates                                                                                          | 2.9 kB  00:00:00
(1/2): epel/x86_64/updateinfo                                                                    | 1.0 MB  00:00:08
(2/2): epel/x86_64/primary_db                                                                    | 6.9 MB  00:00:58
Résolution des dépendances
--> Lancement de la transaction de test
---> Le paquet epel-release.noarch 0:7-11 sera mis à jour
---> Le paquet epel-release.noarch 0:7-12 sera utilisé
--> Résolution des dépendances terminée

Dépendances résolues

========================================================================================================================
 Package                          Architecture               Version                     Dépôt                    Taille
========================================================================================================================
Mise à jour :
 epel-release                     noarch                     7-12                        epel                      15 k

Résumé de la transaction
========================================================================================================================
Mettre à jour  1 Paquet

Taille totale des téléchargements : 15 k
Is this ok [y/d/N]: y
Downloading packages:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
attention : /var/cache/yum/x86_64/7/epel/packages/epel-release-7-12.noarch.rpm: Entête V3 RSA/SHA256 Signature, clé ID 352c64e5: NOKEY
La clé publique pour epel-release-7-12.noarch.rpm n'est pas installée
epel-release-7-12.noarch.rpm                                                                     |  15 kB  00:00:00
Récupération de la clé à partir de file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
Importation de la clef GPG 0x352C64E5 :
ID utilisateur : « Fedora EPEL (7) <epel@fedoraproject.org> »
Empreinte      : 91e9 7d7c 4a5e 96f1 7f3e 888f 6a2f aea2 352c 64e5
Paquet         : epel-release-7-11.noarch (@extras)
Provient de    : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
Est-ce correct [o/N] : o
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Mise à jour  : epel-release-7-12.noarch                                                                           1/2
  Nettoyage    : epel-release-7-11.noarch                                                                           2/2
  Vérification : epel-release-7-12.noarch                                                                           1/2
  Vérification : epel-release-7-11.noarch                                                                           2/2

Mis à jour :
  epel-release.noarch 0:7-12

Terminé !
```

Une fois fait, on peut installer nginx avec la commande `sudo yum install -y nginx`

```
[dmathieu@node1 ~]$ sudo yum install -y nginx
Modules complémentaires chargés : fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.mirrors.proxad.net
 * epel: mirror.nl.leaseweb.net
 * extras: centos.mirrors.proxad.net
 * updates: centos.quelquesmots.fr
Résolution des dépendances
--> Lancement de la transaction de test
---> Le paquet nginx.x86_64 1:1.16.1-1.el7 sera installé
--> Traitement de la dépendance : nginx-all-modules = 1:1.16.1-1.el7 pour le paquet : 1:nginx-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : nginx-filesystem = 1:1.16.1-1.el7 pour le paquet : 1:nginx-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : nginx-filesystem pour le paquet : 1:nginx-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : redhat-indexhtml pour le paquet : 1:nginx-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : libprofiler.so.0()(64bit) pour le paquet : 1:nginx-1.16.1-1.el7.x86_64
--> Lancement de la transaction de test
---> Le paquet centos-indexhtml.noarch 0:7-9.el7.centos sera installé
---> Le paquet gperftools-libs.x86_64 0:2.6.1-1.el7 sera installé
---> Le paquet nginx-all-modules.noarch 1:1.16.1-1.el7 sera installé
--> Traitement de la dépendance : nginx-mod-http-image-filter = 1:1.16.1-1.el7 pour le paquet : 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Traitement de la dépendance : nginx-mod-http-perl = 1:1.16.1-1.el7 pour le paquet : 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Traitement de la dépendance : nginx-mod-http-xslt-filter = 1:1.16.1-1.el7 pour le paquet : 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Traitement de la dépendance : nginx-mod-mail = 1:1.16.1-1.el7 pour le paquet : 1:nginx-all-modules-1.16.1-1.el7.noarch
--> Traitement de la dépendance : nginx-mod-stream = 1:1.16.1-1.el7 pour le paquet : 1:nginx-all-modules-1.16.1-1.el7.noarch
---> Le paquet nginx-filesystem.noarch 1:1.16.1-1.el7 sera installé
--> Lancement de la transaction de test
---> Le paquet nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7 sera installé
--> Traitement de la dépendance : gd pour le paquet : 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : libgd.so.2()(64bit) pour le paquet : 1:nginx-mod-http-image-filter-1.16.1-1.el7.x86_64
---> Le paquet nginx-mod-http-perl.x86_64 1:1.16.1-1.el7 sera installé
---> Le paquet nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7 sera installé
--> Traitement de la dépendance : libxslt.so.1(LIBXML2_1.0.11)(64bit) pour le paquet : 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : libxslt.so.1(LIBXML2_1.0.18)(64bit) pour le paquet : 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : libexslt.so.0()(64bit) pour le paquet : 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64
--> Traitement de la dépendance : libxslt.so.1()(64bit) pour le paquet : 1:nginx-mod-http-xslt-filter-1.16.1-1.el7.x86_64
---> Le paquet nginx-mod-mail.x86_64 1:1.16.1-1.el7 sera installé
---> Le paquet nginx-mod-stream.x86_64 1:1.16.1-1.el7 sera installé
--> Lancement de la transaction de test
---> Le paquet gd.x86_64 0:2.0.35-26.el7 sera installé
--> Traitement de la dépendance : libjpeg.so.62(LIBJPEG_6.2)(64bit) pour le paquet : gd-2.0.35-26.el7.x86_64
--> Traitement de la dépendance : libjpeg.so.62()(64bit) pour le paquet : gd-2.0.35-26.el7.x86_64
--> Traitement de la dépendance : libfontconfig.so.1()(64bit) pour le paquet : gd-2.0.35-26.el7.x86_64
--> Traitement de la dépendance : libXpm.so.4()(64bit) pour le paquet : gd-2.0.35-26.el7.x86_64
--> Traitement de la dépendance : libX11.so.6()(64bit) pour le paquet : gd-2.0.35-26.el7.x86_64
---> Le paquet libxslt.x86_64 0:1.1.28-5.el7 sera installé
--> Lancement de la transaction de test
---> Le paquet fontconfig.x86_64 0:2.13.0-4.3.el7 sera installé
--> Traitement de la dépendance : fontpackages-filesystem pour le paquet : fontconfig-2.13.0-4.3.el7.x86_64
--> Traitement de la dépendance : dejavu-sans-fonts pour le paquet : fontconfig-2.13.0-4.3.el7.x86_64
---> Le paquet libX11.x86_64 0:1.6.7-2.el7 sera installé
--> Traitement de la dépendance : libX11-common >= 1.6.7-2.el7 pour le paquet : libX11-1.6.7-2.el7.x86_64
--> Traitement de la dépendance : libxcb.so.1()(64bit) pour le paquet : libX11-1.6.7-2.el7.x86_64
---> Le paquet libXpm.x86_64 0:3.5.12-1.el7 sera installé
---> Le paquet libjpeg-turbo.x86_64 0:1.2.90-8.el7 sera installé
--> Lancement de la transaction de test
---> Le paquet dejavu-sans-fonts.noarch 0:2.33-6.el7 sera installé
--> Traitement de la dépendance : dejavu-fonts-common = 2.33-6.el7 pour le paquet : dejavu-sans-fonts-2.33-6.el7.noarch
---> Le paquet fontpackages-filesystem.noarch 0:1.44-8.el7 sera installé
---> Le paquet libX11-common.noarch 0:1.6.7-2.el7 sera installé
---> Le paquet libxcb.x86_64 0:1.13-1.el7 sera installé
--> Traitement de la dépendance : libXau.so.6()(64bit) pour le paquet : libxcb-1.13-1.el7.x86_64
--> Lancement de la transaction de test
---> Le paquet dejavu-fonts-common.noarch 0:2.33-6.el7 sera installé
---> Le paquet libXau.x86_64 0:1.0.8-2.1.el7 sera installé
--> Résolution des dépendances terminée


Résumé de la transaction
========================================================================================================================
Installation   1 Paquet (+21 Paquets en dépendance)

Taille totale des téléchargements : 4.5 M
Taille d'installation : 14 M

Installé :
  nginx.x86_64 1:1.16.1-1.el7

Dépendances installées :
  centos-indexhtml.noarch 0:7-9.el7.centos                       dejavu-fonts-common.noarch 0:2.33-6.el7
  dejavu-sans-fonts.noarch 0:2.33-6.el7                          fontconfig.x86_64 0:2.13.0-4.3.el7
  fontpackages-filesystem.noarch 0:1.44-8.el7                    gd.x86_64 0:2.0.35-26.el7
  gperftools-libs.x86_64 0:2.6.1-1.el7                           libX11.x86_64 0:1.6.7-2.el7
  libX11-common.noarch 0:1.6.7-2.el7                             libXau.x86_64 0:1.0.8-2.1.el7
  libXpm.x86_64 0:3.5.12-1.el7                                   libjpeg-turbo.x86_64 0:1.2.90-8.el7
  libxcb.x86_64 0:1.13-1.el7                                     libxslt.x86_64 0:1.1.28-5.el7
  nginx-all-modules.noarch 1:1.16.1-1.el7                        nginx-filesystem.noarch 1:1.16.1-1.el7
  nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7              nginx-mod-http-perl.x86_64 1:1.16.1-1.el7
  nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7               nginx-mod-mail.x86_64 1:1.16.1-1.el7
  nginx-mod-stream.x86_64 1:1.16.1-1.el7

Terminé !
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