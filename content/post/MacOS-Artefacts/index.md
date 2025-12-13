+++
author = "Enzo"
title = "MacOS - Artefects"
date = "2025-12-10"
categories = [
    "Blue Team"
]
tags = [
    "MacOS",
    "Forensic"
]
+++

## Rappel des fichiers

##### .plist
Dans le cours où nous voyons les bases de la forensic sous Mac OS nous avons parler des fichiers ``.plist``, et plus particulièrement des fichiers BLOB. 
Voici un outil supplémentaire pour ouvrir ce type de fichier (dispo sur Mac OS) : 
```Bash 
plutil -p APMExperimentSuiteName.plist 
{
  "APMExperimentFetchSuccessTimestamp" => 1728475253.533066
}
```
Voici un outil disponible sur Linux : 
```Bash
plistutil -p APMExperimentSuiteName.plist 
{
  "APMExperimentFetchSuccessTimestamp" => 1728475253.533066
}
```

##### BDD
Pour naviguer dans les fichiers de base de données nous pouvons utiliser ``DB Browser for SQLite``. Nous pouvons également les extraire et créer des chronologie avec ``apollo`` création de mac4n6 voici le lien du repo ``https://github.com/mac4n6/APOLLO``.

##### Logs
###### Apple System Logs (ASL)
Logs système Apple se trouve à l'emplacement ``/private/var/log/asl/``. Nous pourrons y retrouver les fichiers de logs utmp, wtmp et les détails de connexion. Voici une commande qui nous ouvrira les fichiers de log ASL : ``open -a Console /private/var/log/asl/<log>.asl``.

## Informations Importante

### Version de l'OS
```Bash
cat /System/Library/CoreServices/SystemVersion.plist
...
<key>ProductUserVisibleVersion</key>
<string>15.3.1</string>
<key>ProductVersion</key>
<string>15.3.1</string>
...
```

### Numéro de série
Le numéro de série est situé dans : ``/private/var/folders/*/<DARWIN_USER_DIR/C/locationd/consolidated.db``. c'est une BDD, donc à ouvrir avec DB Browser for SQLite (ou autre DB Reader).

### Fuseau horaire 
Pour connaître le fuseau horaire d'un mac il faut taper la commande : 
```Bash
ls -la /etc/localtime 
lrwxr-xr-x   1 root   wheel   36 Feb 12 22:07 /etc/localtime -> /var/db/timezone/zoneinfo/Asia/Dubai
```
Ici nous pouvons voir que le fuseau est celui de Dubaï. Mais une autre information est intéressante, la date et l'heure, elle correspond au dernier changement de fuseau. 

### Démarrage et redémarrage
Dans le fichier `/private/var/log/system.log` nous pouvons voir ces données, je conseil de faire un `zgrep` pour éviter de les chercher : 
```Bash
zgrep SHUTDOWN_TIME /private/var/log/system.log.* 
Jan 04 03:07:18 MacBook-Pro reboot[27104]: SHUTDOWN_TIME: 1739383459 133812
zgrep BOOT_TIME /private/var/log/system.log.* 
Feb 15 20:24:35 MacBook-Pro bootlog[0]: BOOT_TIME 1739383559 185882
```

### Interface réseau
Les informations importante sur les interface réseau se trouve dans le fichier ``/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist``, nous pouvons l'ouvrir avec un simple `cat`. 

### DHCP
Pour les paramètres DHCP (principalement les baux) nous pouvons les trouver dans `/private/var/db/dhcpclient/leases/en0.plist`

### WiFi
Les informations sur le Wi-Fi se trouve dans le fichier `/Library/Preferences/com.apple.wifi.known-networks.plist`.

### Comptes utilisateurs
Dans le fichier `/private/var/db/dslocal/nodes/Default/users/<user>.plist` nous pouvons récupérer : l'heure de création du compte, l'heure des connexion échoué, les réinitialisation du mot de passe et le nombre de connexion échoué. Pour avoir les historique de connexion des utilisateurs dans le fichier `/Library/Preferences/com.apple.loginwindow.plist`.

### Connexion et déconnexion
Toujours dans les fichiers de logs et toujours avec un `zgrep` : 
```Bash
zgrep login system.log*
OU 
zgrep DEAD_PROCESS system.log*
```

### Volume monté
Les volume qui ont été monté se trouve dans `/Users/<user>/Library/Preferences/com.apple.finder.plist` nous pouvons les lire avec : 
```Bash
plutil -p com.apple.finder.plist
```

### Appareil Apple 
Toujours dans `/Users/<user>/Library/Preferences/` mais dans le fichier ``com.apple.iPod.plist``. Nous pouvons ouvrir ce fichier avec la même commande. 

### Connexion Bluetooth
Les appareils connecté en bluetooth se trouve dans `/Bluetooth/isConnected` c'est une BDD, le fichier s'ouvre donc avec `SQL Browser for SQLite`. 

### Imprimantes connecté
Ce fichier se trouve dans ``/Users/<user>/Library/Preferences/org.cups.PrintingPrefs.plist`` à ouvrir avec `plutil -p`.

