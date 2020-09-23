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

Maintenant que l'on a crée le disque sur notre vm, on va partitionner le disque en utilisant les lignes de commande :

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

On doit monter les partitions automatiquement dna fstab:

```
[dmathieu@localhost ~]$ sudo mount -av
/                         : ignoré
/boot                     : déjà monté
swap                      : ignoré
/srv/site1                : déjà monté
/srv/site2                : déjà monté
[dmathieu@localhost ~]$
```
