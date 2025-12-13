+++
author = "Enzo"
title = "MacOS - Les Bases"
date = "2025-12-10"
categories = [
    "Blue Team"
]
tags = [
    "MacOS",
    "Forensic"
]
+++
## Les systèmes de fichiers
### HFS+

HFS+, aussi appelé Mac OS Extended, est un système de fichiers développé par Apple en 1998 avec Mac OS 8.1. Il remplace le HFS original en offrant une meilleure gestion des fichiers sur les ordinateurs Macintosh.

#### Contexte Historique et Utilisation

HFS+ a été conçu pour surmonter les limitations du HFS, notamment en termes de gestion des grands volumes de stockage et d'allocation d'espace disque. Bien qu'initialement non adapté aux systèmes Unix, il a servi de système de fichiers principal pour Mac OS X et macOS jusqu'en 2017, date à laquelle il a été remplacé par APFS.

Aujourd'hui, HFS+ est considéré comme obsolète. Il reste utilisé sur les appareils antérieurs à 2017, comme les anciens Mac et les iPod. Il est toujours supporté sur macOS 10.12 (Sierra) et les versions antérieures, mais n'est plus le système par défaut sur les versions récentes.


#### Architecture et Structure

##### Composants de Base

HFS+ repose sur une architecture basée sur des secteurs (512 octets) et des blocs (composés d'un ou plusieurs secteurs). Les adresses 32 bits permettent de gérer jusqu'à 2^32 blocs (environ 4 milliards), contre 16 bits pour le HFS.

##### Organisation du Volume

- **Secteurs 0 et 1** : Volume de démarrage.
- **Secteur 2** : En-tête de volume (métadonnées essentielles).

##### Catalogue et Système d'Indexation

Le fichier catalogue est central dans HFS+. Il contient tous les fichiers et dossiers du volume et utilise une structure ``B-Tree`` pour une recherche et une récupération efficaces.

#### Caractéristiques Principales

##### Noms de Fichiers et Encodage

HFS+ supporte des noms de fichiers jusqu'à 255 caractères en UTF-16 (contre 31 pour le HFS). L'encodage UTF-16 avec normalisation Unicode permet une compatibilité internationale.

##### Capacités de Stockage

- Nombre max de fichiers par volume : 2,1 milliards.
- Taille max des fichiers et du volume : 8 exaoctets.

##### Journalisation et Sécurité des Données

La journalisation, introduite en Mac OS X 10.2.2 et standardisée en 10.3, améliore la stabilité des données en permettant une récupération après un crash ou un redémarrage forcé.

#### Limitations et Contraintes

##### Limitation Temporelle

HFS+ ne peut pas gérer les dates postérieures au 6 décembre 2040 en raison de son encodage des horodatages.

#### Évolution et Remplacement

HFS+ a été remplacé par APFS (Apple File System) en 2017 avec macOS High Sierra. APFS est optimisé pour les SSD et offre de meilleures performances. Malgré son obsolescence, HFS+ reste utile pour la compatibilité avec les anciens systèmes macOS et les environnements utilisant du matériel hérité.


### APFS
Apparu en 2017, c'est le système de fichier commun entre iOS, WatchOS, tvOS, MacOS

#### Caractéristiques essentielles de l'APFS

APFS a corrigé la plupart des problèmes HFS+. Quelques exemples sont ci-dessous:

- APFS prend en charge les horodatages jusqu'à 1 nanoseconde.
- Les dates au-delà du 6 février 2040 sont possibles.
- Le chiffrement complet du disque est pris en charge nativement.
- Apple a introduit redirect-on-write, une fonctionnalité de protection contre les crashs. Pour éviter la corruption de données, les données sont écrites sur de nouveaux blocs, et les anciennes sont publiées une fois faites au lieu de réécrire celles existantes.
- Le nombre maximum de fichiers stockés dans le système a été augmenté à 2^63.

Bien qu’APFS ait amélioré beaucoup de choses pour Apple, sa prise en charge du chiffrement complet du disque et du chiffrement matériel et logiciel a rendu les enquêtes forensic très difficiles.

#### Structure
APFS utilise la table de partition GUID (GTP), à l'intérieur de la partition on y trouve un ou plusieurs conteneurs. 
Un conteneur peut contenir un ou plusieurs volumes, chacun l'un à côté de l'autre sans espace. S'il y a un espace libre dans un conteneur il est partagé entre tous les volumes. 

Pour gérer les disques sous Mac OS nous pouvons utiliser ``diskutil`` :  
```Bash
enzo@MacBook-Pro ~ % diskutil 
Disk Utility Tool 
Utility to manage local disks and volumes 
Most commands require an administrator or root user  
WARNING: Most destructive operations are not prompted  
Usage:  diskutil [quiet]  , where  is as follows:
      list                 (List the partitions of a disk)
      info[rmation]        (Get information on a specific disk or partition)
      listFilesystems      (List file systems available for formatting)
      listClients          (List all current disk management clients)
      activity             (Continuous log of system-wide disk arbitration)
      .
      .
      .
      appleRAID      (Perform additional verbs related to AppleRAID)
      coreStorage    (Perform additional verbs related to CoreStorage)
      apfs           (Perform additional verbs related to APFS)
      image          (Perform additional verbs related to DiskImage)
      diskutil  with no options will provide help on that verb`
```

Il est possible d'afficher les types de volumes APFS disponible sur la machine avec la commande ``diskutil apfs list``. 


## Structure des répertoires et domaine
La structure de Mac OS à pas mal de similitude avec celle de Linux.

### Structure des répertoires
```Bash
enzo@MacBook-Pro / % ls
Applications	System		Volumes		cores		etc		opt		sbin		usr
Library		Users		bin		dev		home		private		tmp		var
```
Comme mentionné précédemment, certains de ces répertoires sont très similaires à ce que nous allons trouver dans les systèmes Linux, tels que:

- opt : Ce répertoire contient des fichiers pour les logiciels optionnels, tels que homebrew.
- sbin : Ce répertoire contient des binaires système tels que lancé, ping et mount.
- bin : Ce répertoire contient des binaires tels que chmod, rm et echo.
- dev : Ce répertoire contient des fichiers d'appareils tels que des accessoires Bluetooth.
- private : Ce répertoire contient trois répertoires principaux, `var`, `etc`, et `tmp`, semblable aux mêmes répertoires de noms dans Linux.

### Domaines
macOS organise des fichiers dans différents domaines en fonction de leur utilisation prévue. Le système de fichiers macOS dispose de quatre domaines: local, utilisateur, système et réseau.

#### Domaine local
Le domaine local contient des ressources communes à tous les utilisateurs de l'ordinateur local. Ces ressources sont généralement présentes dans `/Applications`et `/Library`. Le système gère ce domaine mais peut également être géré par des utilisateurs disposant de privilèges administrateur.

#### Domaine système
Le domaine Système contient des logiciels développés et gérés par Apple. Il mappe le répertoire `/System` et contient des applications et configurations de système d'exploitation critiques. Apple ne permet pas aux utilisateurs de modifier ou de supprimer des fichiers dans ce domaine, même avec des privilèges root.

#### Domaine utilisateur
Le domaine utilisateur contient des données et des fichiers utilisateur. Il est situé dans `/Users`. Dans ce répertoire se trouve un répertoire pour chaque utilisateur de la machine. Par défaut, un utilisateur ne peut pas accéder aux fichiers d'un autre utilisateur. Il y a aussi un répertoire de bibliothèque caché à l'intérieur du domaine de l'utilisateur dans le répertoire de chaque utilisateur (situé à `/Users/<user>/Library`). Ce répertoire contient des configurations spécifiques à l'utilisateur et des données d'application.

#### Domaine réseau
Le domaine réseau contient des ressources réseau telles que des imprimantes réseau, des serveurs de partage SMB et d'autres ordinateurs. Les administrateurs réseau gèrent généralement l'accès à ces ressources, que les utilisateurs du réseau local partagent.

## Les formats de fichiers
macOS a une structure de fichier différente des autres systèmes d'exploitation et a ses propres formats de fichiers.
### .plist
Les fichiers .plist ou fichiers de liste de propriétés contiennent des configurations système similaires au Registre Windows dans Microsoft Windows. Par conséquent, comme le fichier Windows Registry, les fichiers .plist sont très importants d'un point de vue forensic. Généralement, deux formats sont utilisés pour les fichiers .plist: 
 - XML 
 - BLOB
 
Nous pouvons utiliser un éditeur de texte pour lire les données des fichiers .plist présents au format XML, mais pour lire les fichiers .plist au format BLOB, nous devons utiliser Xcode, un outil de développement qui peut être installé via l'App Store. L'image ci-dessous montre à quoi ressemble un fichier .plist lorsqu'il est ouvert à l'aide de Xcode.
### .app
Les fichiers .app sont des exécutables d'application souvent trouvés dans le répertoire Applications. L'exécution d'un fichier .app lance l'application, tout comme l'exécution d'un fichier exécutable dans Windows peut lancer une application. Ces fichiers sont 'zippé', et nous pouvons voir le contenu du bundle en utilisant l'option 'Afficher le contenu du paquet'.
### .dmg
Les fichiers .dmg sont des fichiers image de disque macOS. Ces fichiers peuvent être montés facilement dans macOS, et les installateurs utilisent souvent ce format.
### .kext
Bien que obsolètes dans les nouvelles versions de macOS, les fichiers .kext sont des fichiers d'extension du noyau. Les extensions Kernel fonctionnent de la même manière que les pilotes dans Windows, donnant accès au noyau du système d'exploitation aux applications tierces.

### .dylib
Ce sont des fichiers de bibliothèque chargés dynamiquement. Ils contiennent du code partagé utilisé par différents programmes. Ils sont similaires aux fichiers DLL dans Windows ou .so fichiers sous Linux.

## Les défis de l'acquisition
Apple a rendu ses produits très peu amicaux à la forensic. Comme nous l’avons déjà mentionné, Apple a résisté à une forte pression, même de la part des agences gouvernementales américaines, pour ouvrir ses plateformes et faciliter les enquêtes forensic. Mais qu'est-ce qui rend macOS si hostile pour les enquêtes ? Passons en revue certains défis qui rendent la prise d'une image de disque complète d'un appareil macOS dur.

### Accès au disque 
Dans les nouveaux Macbooks, les disques SSD sont soudés à la carte mère. Cela signifie que le retrait du SSD n'est pas une option sans risquer d'endommager le lecteur ou la machine dans son ensemble. Dans les appareils où les SSD ne sont pas soudés, tels que les appareils plus anciens, ils utilisent souvent des interfaces propriétaires, ce qui rend difficile leur connexion au matériel d'imagerie.

### Chiffrement matériel
Même si nous pouvons accéder physiquement au SSD sur un Mac, nous ne serons pas en mesure d'en récupérer ou d'en extraire des données, car le lecteur est chiffré par un chiffrement matériel. À partir des puces basées sur T2, Apple stocke la clé de chiffrement du SSD dans une enclave sécurisée distincte du CPU. Cela signifie que si la carte mère échoue ou est autrement indisponible, les données du SSD chiffré sont perdues et ne peuvent pas être récupérées.

### Chiffrement FileVault
Apple utilise FileVault pour ajouter une autre couche au cryptage macOS. FileVault lie le chiffrement des données avec le mot de passe de l'utilisateur, garantissant que les données sont chiffré tant que l'utilisateur n'a pas entré son mot de passe. Cela signifie que même si un système Mac est activé en utilisant le même matériel, nous ne pouvons pas accéder aux données à moins que le mot de passe de l'utilisateur ne déverrouille le FileVault. Par conséquent, même si nous démarrons la machine en récupération, ce qui est le moyen le plus fiable de prendre une image de disque complète du SSD Mac, nous devrons toujours déverrouiller FileVault pour accéder aux données en fournissant soit le mot de passe de l'utilisateur, soit, si une organisation gère le Mac, la clé d'accès de l'organisation. Bien que FileVault n'empêche pas un enquêteur d'obtenir une image de disque, l'enquêteur aura besoin du mot de passe ou des clés d'accès organisationnel pour déverrouiller le volume et accéder aux données.

### Protection de l'intégrité du système (SIP)
La protection de l'intégrité du système (SIP) est une fonctionnalité qui protège le noyau contre l'accès non autorisé, l'injection de code, le débogage ou les modifications générales. SIP peut souvent empêcher l'accès à la mémoire ou à certaines parties du disque, même avec l'accès root. Par conséquent, la désactivation de SIP peut être une bonne idée avant d’acquérir une image. Cependant, comme cela nécessite un démarrage dans la récupération, cela peut entraîner la perte de données volatiles et des modifications du disque. SIP peut être désactivé en démarrant dans la récupération, en ouvrant le terminal et en utilisant la commande `csrutil disable`.


### Quelles possibilités ? 
Nous pouvons envisager les possibilités suivantes d'acquisition de données à partir d'un Mac.

- Utilisez un outil propriétaire tel que Magnet AXIOM ou Cellebrite, accordez un accès complet au disque et imagez un système en direct.
- Si le mot de passe de l'utilisateur est connu et que la machine est physiquement disponible, nous pouvons démarrer en récupération, désactiver les fonctionnalités de sécurité et prendre une image disque à l'aide du terminal à l'aide d'outils tels que dd, hdiutil ou dc3dd.
- Après avoir démarré dans la récupération et déverrouillé le lecteur à l'aide du mot de passe utilisateur, le Mac peut être mis en mode de partage Mac ou en mode Target (pour les systèmes plus anciens). En connectant le Mac à un autre appareil à l'aide de Firewire ou Thunderbolt, une acquisition logique peut être effectuée (pour le mode de partage Mac), ou une image de disque complète peut être prise (si le mode Target est disponible). Cependant, le mode Target n'est plus disponible dans les nouveaux Mac avec des puces en silicium Apple.

## Montage d'une image APFS

POur commencer nous allons énumérer les volumes disponible sur l'image APFS : 
```Bash
ubuntu@ubuntu:~# apfsutil mac-disk.img 
Found partitions:
69646961-6700-11AA-11AA-00306543ECAC 68CB0FFE-F676-47D6-D1A2-5707D06D3E49 0000000000000028 00000000000FA027 0000000000000000 iBootSystemContainer
7C3457EF-0000-11AA-11AA-00306543ECAC 449DFC0C-7E1F-44D5-6A9F-7EA2C2AF0ADC 00000000000FA028 0000000002800027 0000000000000000 Container
52637672-7900-11AA-11AA-00306543ECAC A9432466-4751-47B7-1BBC-45B7B70465DE 0000000002800028 00000000031FFFD7 0000000000000000 RecoveryOSContainer
First APFS partition is 1
...
```

Pour monter l'image nous allons utiliser l'outil ``apfs-fuse``:
```Bash
ubuntu@ubuntu:/home/ubuntu# apfs-fuse mac-disk.img mac/ 
ubuntu@ubuntu:/home/ubuntu# ls mac 
private-dir  root
ubuntu@ubuntu:/home/ubuntu# ls mac/root/Users 
ubuntu@ubuntu:/home/ubuntu#
```
Nous n'avons pas monté le bon volume. Nous devons monté le volume 4 : 

```Bash
ubuntu@ubuntu:/home/ubuntu# apfs-fuse -v 4 mac-disk.img mac
ubuntu@ubuntu:/home/ubuntu# ls mac/root/Users
Shared  enzo
```