+++
author = "Enzo"
title = "Mobile - Analyse Android"
date = "2025-12-09"
categories = [
    "Mobile"
]
tags = [
    "Android",
    "Mobile",
    "Forensic",
    "Analyse"
]
+++

## Architecture Android

L'architecture d'Android est superposée et modulaire, ce qui la rend polyvalente et complexe d'un point de vue Forensic.
![](5e8dd9a4a45e18443162feab-1747826237632.svg)

Elle est composé des couche suivantes : 
#### Noyau Linux
C'est la base du système, elle va fournir des fonctionnalités de base du système. Elle agit comme couche entre l'hardware et le software

- Services de base
- Gestion des processus
- Gestion de la mémoire
- Conducteurs de dispositifs

#### Bibliothèques Native
Elles fournissent des fonctionnalités de base du système et aux applications.

- Bibliothèques du système
- Cadres pour les médias
- Moteur de base de données SQLite
- Moteur de navigateur WebKit

#### Framework Application
Elle fournit des API pour des niveau plus haut, comme la localisation, la téléphonie ... 

- API pour le développement d'applications
- Gestion des ressources
- Interaction des composants
- Traitement des services

#### Application
La couche la plus haute de l'architecture Android. Elle comprend le système et les applications installé par l'utilisateur. C'est la principale source de données dans une enquêtes Forensic. 

- Demandes d'utilisation
- Applications du système
- Applications de tiers


### Système de fichiers Android

Android utilise un système de fichier basé sur Linux qui partitionne et met des "couches" pour gérer les données de manière sécurisée et efficace. La structure est personnalisée en fonction du matériel et de l'OS.   
![](5e8dd9a4a45e18443162feab-1747796686545-1.png)

### Partitions du système de fichier
```Bash
        
├── system/                  → Android OS system files (read-only in user mode) │  ├── bin/                     → System binaries 
│   ├── lib/                 → Shared libraries 
│   └── framework/           → Java framework .jar files 
│ 
├── data/                    → Main user data partition 
│   ├── app/                 → Installed APKs 
│   ├── data/                → App private data 
│   ├── misc/                → Misc system info (e.g., WiFi configs) 
│   ├── media/               → Encrypted storage mount point 
│   └── system/              → User accounts, settings 
│ 
├── sdcard/ (or /storage/emulated/0) → User files, photos, downloads 
│ 
├── vendor/                 → OEM-specific binaries/libraries 
│ 
└── dev/, proc/, sys/       → Kernel and device interfaces (like Linux)`
```

### Analyse d'une image 
Nous avons un fichier ``.ad1``, nous l'importons dans FTK Imager. 
Ensuite nous avons accès à certains fichiers de l'appareil suspect : 
![](Pasted-image-20251001170204.png)

Le but de l'exercice ici est de trouver le numéro de série qui se trouve dans ``/system/build.prop``: 
![](Pasted-image-20251001170322.png)

## Artefacts 

Pour commencer nous allons devoir poser les bases et se demandé quelles information vont être importantes ou non. 

Voici une liste d'artefacts qui peuvent être intéressant selon notre enquête. 

#### SMS et Journaux d'Appels
Emplacement :
 - SMS (et MMS) : /data/data/com.android.providers.telephony/databases/mmssms.db
 - Journaux d'appel : /data/data/com.android.providers.contacts/databases/calllog.db

#### Contacts
Emplacement : 
 - Contacts : /data/services/com.android.providers.contacts/databases/contacts2.db

#### Historique du navigateur
Emplacement (Chrome) : 
 - /data/data/com.android.chrome/app-chrome/par défaut/history

#### Données de localisation
Emplacement : 
 - /data/data/com.google.android.gms/databases/
   (location.db, networklocations.db ou com.google.android.location)

#### Mediatech
Emplacement : 
 - /sdcard/DCIM/
 - /sdcard/Pictures/
 - /sdcard/WhatsApp/Media/

#### Données d'applications
Emplacement : 
 - /data/data/(app.package.name)/
 - Par exemple: /data/data/com.instagram.android/ ou /data/com.snapchat.android/

#### Compte utilisateurs
Emplacement : 
 - /data/system/users/0/accounts.db
 - /data/data/com.google.android.gms/databases

#### Information sur les applications installé
Emplacement : 
 - /system/packages.xml


## Outils commercial

Il y a 3 types d'exfiltration de données sur android : 

| Type                | Description                                                                                                                                                                                                                                                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Logique             | Comme en utilisant une sauvegarde pour obtenir des données au niveau de l'utilisateur.                                                                                                                                                                             |
| Système de fichiers | Donne l'accès aux dossiers et aux fichiers système. Il permet un accès plus profond que l'acquisition logique, y compris les répertoires d'applications et le stockage interne, ce qui est utile pour examiner les données et les configurations des applications. |
| Physique            | Une copie bit par bit de la mémoire complète de l'appareil, y compris des données supprimées, un espace non alloué et des zones du système inaccessibles par des acquisitions de plus haut niveau.                                                                 |

### Les outils

| Nom                               | Fonction                             | Utilisation                                                                                                    |
| --------------------------------- | ------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| **ALEAPP**                        | Artifact Parser                      | Extracts and parses key Android artifacts (e.g., app data, location, usage stats).                             |
| **Autopsy + Android Modules**     | GUI Forensics Suite                  | Examines logical dumps with plugin support for call logs, messages, and app data.                              |
| **Cellebrite UFED**               | Commercial Mobile Forensics Platform | Physical, file system, and logical Android (and iOS) device extraction.                                        |
| **Magnet AXIOM**                  | Commercial Suite                     | Ingests Android images and categorizes artifacts using timeline, chats, media, etc.                            |
| **Oxygen Forensic Detective**     | Commercial All-in-One Tool           | Recovers deleted data, decrypts apps, and parses communications and cloud data.                                |
| **ADB (Android Debug Bridge)**    | Command-line Interface               | Communicates with the Android device, collects logs, and performs manual file extraction (root may be needed). |
| **TWRP Recovery**                 | Custom Recovery Interface            | Used to boot into a custom recovery mode for image acquisition or data access.                                 |
| **LiME (Linux Memory Extractor)** | Memory Dumping Tool                  | It captures volatile memory (RAM) from an Android device and is used for live memory forensics.                |
| **Andriller**                     | Device Analysis + Unlock Tool        | Extracts device data, PIN cracking, and report generation from Android backups.                                |
| **ADB-Backup Extractors**         | Backup Utilities                     | Converts Android ADB backups (`.ab` files) into accessible `.tar` archives.                                    |
| **Protobuf Parsers**              | Data Format Parser                   | Parses Android usage stats, app events, and settings stored in Protobuf format.                                |

## Analyse des artefacts

### SMS
On se rends dans le fichier nécessaire :
```MSDOS
cd C:\Users\Administrator\Desktop\Evidence\suspicious_device\data\data\com.android.providers.telephony\databases

sqlite3 mmssms.db
.tables
```
![](Pasted-image-20251002160557.png)
On envoie une requête SQL pour nous afficher TOUT les messages de la base sms : 
![](Pasted-image-20251002160718.png)


### Journal d'appel
Comme à l'étape précédente, on se rend au chemin nécessaire : 
```MSDOS
cd C:\Users\Administrator\Desktop\Evidence\suspicious_device\data\data\com.android.providers.contacts\databases

sqlite3 mmssms.db
.tables
```
![](Pasted-image-20251002161210.png)

Et ainsi de suite pour les différentes base de données. 


## aLEAPP
Nous venons de faire une analyse d'artefact à la main, c'est fastidieux de faire ça. Nous pouvons donc utilisé un outil dont nous avons parlé tout à l'heure : aLEAPP

### Analyse Android
aLEAPP analyse et fournit un rapport lisible par nous. Il possède 2 interface, une graphique et l'autre en ligne de commande.

#### GUI  
``python aleappgui.py``
![](Pasted-image-20251002163345.png)
Il prend des fichier .zip/.tar/.gz.

Une fois le fichier en .zip donné, un fichier de sortie et lancé l'analyse nous pouvons cliquer sur `Open Report and Close` Le rapport s'ouvrira dans le navigateur. 
![](Pasted-image-20251002163726.png)
