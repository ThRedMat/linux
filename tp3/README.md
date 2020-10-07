# TP3 : systemd

## I. Services systemd

### 1. Intro

- Nombre de services disponibles :

```
[vagrant@localhost ~]$ systemctl list-unit-files --type=service | tail -1 | cut -d " " -f 1
155
```

- Nombre de services actifs :

```
[vagrant@localhost ~]$ systemctl -t service --all | grep running | wc -l
17
```

- Nombre de service failed ou inactif :

```
[vagrant@localhost ~]$ systemctl -t service --all | grep -E 'inactive|failed' | wc -l
68
```

- Nombre de service enabled :

```
[vagrant@localhost ~]$ systemctl list-unit-files --type=service | grep enabled | wc -l
32
```

### 2. Analyse d'un service

### Path de l'unité nginx.service

```
[vagrant@localhost ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
```

On retrouve la configuration de nginx ici : `/usr/lib/systemd/system/nginx.service`

### Analyse du contenu de l'unité

```
[vagrant@localhost ~]$ systemctl cat nginx
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Des commandes sont executées quand ce service se lance. Pour chaque commandes le premier argument doit être un chemin absolu vers un executable ou un ficher sans le slash:

```
ExecStart=/usr/sbin/nginx
Ses commandes s'execute avant ou après ExecStart:

ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
C'est le chemin vers le PID du service:

PIDFile=/run/nginx.pid
Le type du process de démarrage:

Type=forking
La commande pour enclencher un reload de la config du service

ExecReload=/bin/kill -s HUP \$MAINPID
description du service:

Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target
```

#### voici la liste des services qui contiennent ligne WantedBy=multi-user.target:

```
[vagrant@localhost ~]$ grep 'WantedBy=multi-user.target' -r . | grep -r "WantedBy=multi-user.target" /run/systemd/transient//etc/systemd/system/* /run/systemd/generator/* /usr/lib/systemd/system/*
grep: /run/systemd/transient//etc/systemd/system/*: No such file or directory
/usr/lib/systemd/system/auditd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/brandbot.path:WantedBy=multi-user.target
/usr/lib/systemd/system/chronyd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/chrony-wait.service:WantedBy=multi-user.target
/usr/lib/systemd/system/cpupower.service:WantedBy=multi-user.target
/usr/lib/systemd/system/crond.service:WantedBy=multi-user.target
/usr/lib/systemd/system/ebtables.service:WantedBy=multi-user.target
/usr/lib/systemd/system/firewalld.service:WantedBy=multi-user.target
/usr/lib/systemd/system/fstrim.timer:WantedBy=multi-user.target
/usr/lib/systemd/system/gssproxy.service:WantedBy=multi-user.target
/usr/lib/systemd/system/irqbalance.service:WantedBy=multi-user.target
/usr/lib/systemd/system/machines.target:WantedBy=multi-user.target
/usr/lib/systemd/system/NetworkManager.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nfs-client.target:WantedBy=multi-user.target
/usr/lib/systemd/system/nfs-rquotad.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nfs-server.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nfs.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nginx.service:WantedBy=multi-user.target
/usr/lib/systemd/system/postfix.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rdisc.service:WantedBy=multi-user.target
/usr/lib/systemd/system/remote-cryptsetup.target:WantedBy=multi-user.target
/usr/lib/systemd/system/remote-fs.target:WantedBy=multi-user.target
/usr/lib/systemd/system/rhel-configure.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rpcbind.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rpc-rquotad.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rsyncd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rsyslog.service:WantedBy=multi-user.target
/usr/lib/systemd/system/sshd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/tcsd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/tuned.service:WantedBy=multi-user.target
/usr/lib/systemd/system/vboxadd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/vboxadd-service.service:WantedBy=multi-user.target
/usr/lib/systemd/system/vmtoolsd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/wpa_supplicant.service:WantedBy=multi-user.target
```

## A. Serveur web

Configuration du fichier serveurtp3.service dans /etc/systemd/system

On tape la commande ```sudo systemctl daemon-reload````pour demander à systemd de relire tous les fichiers afin qu'il découvre le nôtre

On peut démarrer le serveur :

```
[vagrant@localhost ~]$ systemctl start serveurtp3
[vagrant@localhost ~]$ systemctl status serveurtp3
● serveurtp3.service - Serveur TP3
   Loaded: loaded (/etc/systemd/system/serveurtp3.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-10-07 14:39:43 UTC; 7s ago
  Process: 1629 ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=${PORT}/tcp (code=exited, status=0/SUCCESS)
 Main PID: 1636 (python2)
   CGroup: /system.slice/serveurtp3.service
           └─1636 /usr/bin/python2 -m SimpleHTTPServer 8080
```

On voit bien qu'il est en fonction.

On curl le serveur pour prouver qu'il fonctionne bien :

```
[vagrant@localhost ~]$ curl localhost:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><html>
<title>Directory listing for /</title>
<body>
<h2>Directory listing for /</h2>
<hr>
<ul>
<li><a href="bin/">bin@</a>
<li><a href="boot/">boot/</a>
<li><a href="dev/">dev/</a>
<li><a href="etc/">etc/</a>
<li><a href="home/">home/</a>
<li><a href="lib/">lib@</a>
<li><a href="lib64/">lib64@</a>
<li><a href="media/">media/</a>
<li><a href="mnt/">mnt/</a>
<li><a href="opt/">opt/</a>
<li><a href="proc/">proc/</a>
<li><a href="root/">root/</a>
<li><a href="run/">run/</a>
<li><a href="sbin/">sbin@</a>
<li><a href="srv/">srv/</a>
<li><a href="swapfile">swapfile</a>
<li><a href="sys/">sys/</a>
<li><a href="tmp/">tmp/</a>
<li><a href="usr/">usr/</a>
<li><a href="vagrant/">vagrant/</a>
<li><a href="var/">var/</a>
</ul>
<hr>
</body>
</html>
```

## B. Sauvegarde