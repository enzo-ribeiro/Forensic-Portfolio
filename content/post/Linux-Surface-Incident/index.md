+++
author = "Enzo"
title = "Linux - Surface d'Incident"
date = "2025-12-09"
categories = [
    "Blue Team"
]
tags = [
    "Linux",
    "Forensic",
    "Analyse"
]
+++

## Introduction 
La surface d'incident fait référence aux points d'entré du système. 

Il y a une différence entre Surface d'Attaque et une Surface d'Incident. 

Surface d'Attaque :
 - Ports ouverts
 - Services de course
 - Exécution de logiciels ou d'applications présentant des vulnérabilités
 - Communication réseau

Face à la surface d'attaque, le but est de la minimiser :
 - Identifier et corriger les vulnérabilités
 - Minimiser l'utilisation de services indésirables
 - Vérifiez les interfaces avec lesquelles l'utilisateur interagit
 - Minimiser les services, applications, ports, etc. exposés publiquement

Surface d'Incident désigne elle, tous les domaines de système impliqué dans la détection, la gestion et la réponse à un incident de sécurité. 

Exemple de Surface d'Incident :
- Journaux système
- auth.log, syslog, krnl.log, etc
- Trafic réseau
- Processus en cours d'exécution
- Services de course
- L'intégrité des fichiers et des processus

Comprendre la surface de l’incident est essentiel pour répondre efficacement à une attaque en cours, atténuer les dommages, récupérer les systèmes affectés et appliquer les leçons apprises pour prévenir de futurs incidents.
## Processus et Communication Réseau

Les processus et la communication réseau sont essentiels à tout système d'exploitation lors des enquêtes sur les incidents. La surveillance et l'analyse des processus, notamment ceux liés à la communication réseau, peuvent contribuer à identifier et à résoudre les incidents de sécurité. Les processus en cours d'exécution sont un élément clé de la surface d'incident Linux , car ils peuvent constituer une source potentielle de preuves d'une attaque.
### Analyse d'un processus simple
Pour commencer on compile le processus qui est un simple .c
```Bash
gcc simple.c -o /tmp/simple
/tmp/simple
```
Une fois la notre binaire lancé, nous ppouvons ouvrir un nouveau terminal et voir les processus en cours d'exécution avec la commande ``ps aux``:
![](SCR-20251004-lada.png)
- `a` : Affiche les processus pour tout les utilisateurs
- `u` : Affiche le format orienté utilisateur (inclut l'utilisateur et l'heure de début)
- `x` : Inclut les processus non attachés à un terminal

La sortie de cette commande nous donne ces informations :
Shows ps aux output

La sortie fournit les informations suivantes :
- UTILISATEUR : L'utilisateur qui possède le processus.
- PID : ID du processus.
- %CPU : pourcentage d'utilisation du processeur.
- %MEM : Pourcentage d'utilisation de la mémoire.
- VSZ : Taille de la mémoire virtuelle.
- RSS : Resident Set Size (mémoire actuellement utilisée).
- TTY : Terminal associé au processus.
- STAT : État du processus (par exemple, R pour exécution, S pour veille, Z pour zombie).
- START : Heure de début du processus.
- COMMANDE : Commande qui a démarré le processus

Nous pouvons lier cette commande avec un ``grep`` pour avoir un résultat précis.
Avec le ``PID`` nous pouvons faire une recherche plus appronfondie, comme les ressources qu'utilse notre binaire. Nous allons faire ça avec la commande ``lsof``.
```Bash
lsof -p <PID>
```
![](SCR-20251004-lfdn.png)
### Analyse d'un processus avec communication réseau
Dans la plupart des scénarios, les processus communicant avec un IP externe mérites d'être examinés. Pour expliquer comment ça se passe nous allons exécuter un processus appelé ``netcom``. 
```Bash
./netcom
ps aux
```
![](Pasted-image-20251004125812.png)Donc nous voyons bien la ligne concernant notre binaire.
Il possède le PID 2130, mais nous allons d'abord voir si une connexion vers l'extérieur à lieu avec la commande suivante : 
```Bash
lsof -i -P -n 
```
![](Pasted-image-20251004130148.png)
 - `lsof` : List Open Files, affiche les infos sur les fichiers ouvert par les processus
 - `i` : affiche les infos sur les connexions réseau, y compris les sockets
 - `P` : affiche les ports utilisés
 - `n` : transforme les nom DNS en IP

Maintenant que nous savons qu'il y a une connexion suspecte, nous allons utiliser l'outil ``osqueryi`` :
```Bash
sudo osqueryi
SELECT pid, fd, socket, local_address, remote_address FROM process_open_sockets WHERE pid = <PID>;
```
![](Pasted-image-20251005130848.png)

Voici quand il est important d'investiguer : 
 - Un processus exécuté à partir d'un répertoire tmp (le contexte est important).
 - Un processus parent-enfant suspect.
 - Processus avec une connexion réseau suspecte.
 - Processus orphelin. Tous les processus orphelins ne sont pas suspects, mais ceux qui ne sont associés à aucun processus parent après exécution méritent d'être examinés.
 - Processus suspects exécutés via une tâche cron .
 - Processus ou binaires liés au système exécutés à partir du répertoire tmp ou des répertoires utilisateur.

## Persistance

La persistance désigne généralement les techniques utilisées par les adversaires pour maintenir l'accès à un système compromis après l'exploitation initiale. Pour comprendre comment différents incidents sont identifiés à différents points du poste Linux , nous commencerons par exécuter l'attaque, puis examinerons où et comment les empreintes d'attaque se reflètent.

### Création de compte
Pour avoir une persistance sur un Endpoint Linux généralement les attaquants créer un utilisateur. Voici les commandes que l'attaquant va utiliser : 
```Bash
sudo useradd attacker -G sudo
sudo passwd attacker
echo "attacker ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
```

Pour analyser ces traces, nous allons examiner les logs du système. Pour nous rendre compte des différents logs que nous avons à notre disposition, nous pouvons nous rendre dans : ``/var/log`` : 
```Bash
cd /var/log/
ls -al

total 3108
drwxrwxr-x  16 root              syslog             4096 Sep  5 00:00 .
drwxr-xr-x  14 root              root               4096 Feb 27  2022 ..
-rw-r--r--   1 root              root              35148 Aug 20 07:34 Xorg.0.log
-rw-r--r--   1 root              root             116188 Feb 16  2024 Xorg.0.log.old
-rw-r--r--   1 root              root                  0 Sep  1 00:00 alternatives.log
-rw-r--r--   1 root              root               8021 Aug 22 06:57 alternatives.log.1
-rw-r--r--   1 root              root               3001 Feb 16  2024 alternatives.log.2.gz
drwxr--r-x   3 root              root               4096 Feb 27  2022 amazon
-rw-r-----   1 root              adm                   0 Aug 20 07:34 apport.log
-rw-r-----   1 root              adm                 398 Feb 16  2024 apport.log.1
drwxr-xr-x   2 root              root               4096 Sep  5 06:52 apt
-rw-r-----   1 syslog            adm               46892 Sep  5 21:30 auth.log
-rw-r-----   1 syslog            adm               72850 Aug 31 23:30 auth.log.1
...
...
...
```

Dans ce cas nous pouvons regarder dans le fichier ``auth.log`` : 
```Bash
sudo cat auth.log | grep useradd

Sep  5 21:18:19 tryhackme sudo:   ubuntu : TTY=pts/0 ; PWD=/home ; USER=root ; COMMAND=/usr/sbin/useradd attacker -G sudo
Sep  5 21:18:19 tryhackme useradd[184928]: new group: name=attacker, GID=1001
Sep  5 21:18:19 tryhackme useradd[184928]: new user: name=attacker, UID=1001, GID=1001, home=/home/attacker, shell=/bin/sh, from=/dev/pts/0
Sep  5 21:18:45 tryhackme sudo:   ubuntu : TTY=pts/0 ; PWD=/home ; USER=root ; COMMAND=/usr/sbin/useradd attacker -G sudo
```
Dans l'output de la commande nous voir la création de l'utilisateur en détail.

Le fichier ``/etc/passwd``peut également nous intéresser, car nous verrons tout les utilisateurs présent sur la machine : 
```Bash
sudo /etc/passwd

kernoops:x:113:65534:Kernel Oops Tracking Daemon,,,:/:/usr/sbin/nologin
lightdm:x:114:121:Light Display Manager:/var/lib/lightdm:/bin/false
whoopsie:x:115:123::/nonexistent:/bin/false
dnsmasq:x:116:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
avahi-autoipd:x:117:124:Avahi autoip daemon,,,:/var/lib/avahi-autoipd:/usr/sbin/nologin
usbmux:x:118:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
rtkit:x:119:125:RealtimeKit,,,:/proc:/usr/sbin/nologin

avahi:x:120:126:Avahi mDNS daemon,,,:/var/run/avahi-daemon:/usr/sbin/nologin
fwupd-refresh:x:130:136:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
attacker:x:1001:1001::/home/attacker:/bin/sh
```
Dans cet output, nous pouvons voir ces détail : 
 - Nom d'utilisateur.
 - L'espace réservé au mot de passe est représenté par x ou *, indiquant que le mot de passe est stocké dans le fichier /etc/shadow.
 - ID utilisateur attribué à l'utilisateur
 - ID de groupe attribué à l'utilisateur.
 - Répertoire personnel de l'utilisateur.
 - Chemin vers le shell par défaut de l'utilisateur.

### Cron job
Cron est un planificateur de tâches basé sur le temps. Il va nous permettre d'effectuer des tâches sans que nous intervenons sur le système (commandes, exécution de script ...). 

La commande ``crontab -e`` nous permet d'ajouter une tache cron, mais aussi de voir les tâches qui s'exécute automatiquement. 

```Bash
crontab -e

# Edit this file to introduce tasks to be run by cron. 
#  
# Each task to run has to be defined through a single line 
# indicating with different fields when the task will be run 
# and what command to run for the task 
#  
# To define the time you can provide concrete values for # minute (m), hour (h), day of month (dom), month (mon), # and day of week (dow) or use '*' in these fields (for 'any'). 
#  
# Notice that tasks will be started based on the cron's system 
# daemon's notion of time and timezones. 
#  
# Output of the crontab jobs (including errors) is sent through 
# email to the user the crontab file belongs to (unless redirected). 
#  
# For example, you can run a backup of all your user accounts 
# at 5 a.m every week with: # 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/ 
#  
# For more information see the manual pages of crontab(5) and cron(8) 
#  
# m h  dom mon dow   command 
@reboot /path/to/malicious/script.sh
```
Ici, à chaque redémarrage, le script ``script.sh`` est lancé.
Nous pouvons voir quel utilisateur à des tâches cron au chemin suivant : ``/var/spool/cron/crontabs/``.


### Services 
C'est une autre méthode qui permet d'assurer la persistance, tout comme la cron task ci dessus, les services vont nous permettent. La tâche s'exécutera en arrière plan et à chaque démarrage de la machine.

Pour analyser un service qui nous paraît suspect nous pouvons nous rendre dans ``/etc/systemd/system/<service qui nous paraît suspect>``.
![](Pasted-image-20251005140053.png)

Ici le service benign.service est suspect : 
![](Pasted-image-20251005140200.png)
pas d'utilisateur, pas de groupe, lancement dans le /tmp tout paraît suspect.

## Footprint sur le disque

Des empreintes sur le système seront présentes, les plus évidente seront : 
 - ``/etc/passwd``: ce fichier contiendra des informations sur les comptes utilisateurs
 - ``/etc/shadow``: il contiendra les mot de passe hachés des comptes
 - ``/etc/group``: définit les groupes des utilisateurs
 - ``/etc/sudoers``: configure les autorisations sudo

### Enquête fictive sur un paquet malveillant
1) Création du paquet 
	 1.1) Création des répertoires
	 ```Bash
	 mkdir malicious-packages
	 cd malicious-packages
	 mkdir DEBIAN
	 ```
	 1.2) Création du fichier de contrôle
	 ```bash
	 nano control
	 
	 Package: malicious-package
	 Version: 1.0
	 Section: base
	 Priority: optional
	 Architecture: all
	 Maintainer: attacker@test.com
	 Description: This is a malicious Package
	 ```
	 1.3) Ajout du script
	 ```Bash
	 nano postint
	 
	 #!/bin/bash
	 # Malicious post-installation script
	 # It will run this script after installation

	 # Print a suspicious message - for demonstration
	 echo "something suspicious"
	 ```
2) Rendre le script exécutable
```Bash
chmod 755 malicious-package/DEBIAN/postinst
```
3) Construire le paquet
```Bash
dpkg-deb --build malicious-package
```
4) Installation du paquet
```Bash
dpkg -i malicious-package.deb
```
5) Examen des log d'installation
```Bash
grep " install " /var/log/dpkg.log
2024-06-13 06:47:05 install linux-image-5.15.0-1063-aws:amd64 <none> 5.15.0-1063.69~20.04.1
2024-06-13 06:47:06 install linux-aws-5.15-headers-5.15.0-1063:all <none> 5.15.0-1063.69~20.04.1
2024-06-13 06:47:09 install linux-headers-5.15.0-1063-aws:amd64 <none> 5.15.0-1063.69~20.04.1
2024-06-24 19:17:39 install osquery:amd64 <none> 5.12.1-1.linux
2024-06-26 05:54:38 install sysstat:amd64 <none> 12.2.0-2ubuntu0.3
2024-06-26 14:32:05 install malicious-package:amd64 <none> 1.0
```

## Logs Linux
- Syslog :
	- Emplacement: `/var/log/syslog`
	- Ceci est utile pour identifier les événements, erreurs et avertissements à l'échelle du système. Cela peut fournir des informations sur les problèmes liés aux composants ou services du système.
	- Il contient des messages système généraux, notamment des messages du noyau, des services système et des journaux d'application.
	- Ce fichier journal est utile pour identifier les événements, les erreurs et les avertissements à l’échelle du système.
	- Il peut fournir des informations sur les problèmes liés aux composants ou aux services du système.

- Messages : 
	- Emplacement: `/var/log/messages`
	- Similaire à `syslog`, ce fichier comprend les messages système et les journaux du noyau.
	- Utile pour diagnostiquer les problèmes du système et suivre l'activité du système.
	- La découverte d’entrées inhabituelles liées à des erreurs matérielles ou de noyau peut signaler une tentative de falsification des composants du système.
	- Par exemple, des messages répétés de panique du noyau pourraient indiquer une attaque par déni de service ciblant la stabilité du système.

- Authentification :
	- Emplacement: `/var/log/auth.log`
	- Ce fichier enregistre les tentatives d'authentification, y compris les tentatives de connexion réussies et échouées.
	- Il s'agit d'un fichier journal important pour détecter les tentatives d'accès non autorisées et les attaques par force brute.
	- Par exemple, la détection de plusieurs tentatives de connexion infructueuses à partir d'une adresse IP inconnue ou d'heures de connexion inhabituelles peut indiquer une attaque par force brute ou une tentative d'accès non autorisé.

Voici quelques exemples clés d’événements pouvant être classés comme incidents :

- Tentatives de connexion échouées.
- Tentative de connexion réussie mais à un moment inhabituel (après les heures de bureau ou le week-end -> selon le contexte de l'entreprise).
- Communication réseau suspecte.
- Erreurs système.
- Création de compte utilisateur sur le serveur sensible.
- Le trafic sortant est initié à partir du serveur Web.
