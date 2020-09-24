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

```

```

```

```
