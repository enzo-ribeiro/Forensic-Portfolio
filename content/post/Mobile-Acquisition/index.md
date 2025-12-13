+++
author = "Enzo"
title = "Mobile - Acquisition"
date = "2025-12-09"
categories = [
    "Blue Team"
]
tags = [
    "Mobile",
    "Forensic",
    "Acquisition"
]
+++
## Introduction

Pourquoi les appareils mobiles sont des mines d'or de données ? Car il contiennent une large gamme de donnée : 

- Carnets d'appel et de discussion
- GPS et données de navigation
- Documents et téléchargements
- Images et vidéo
- Historique de navigation
- Historique WiFi
- Données spécifiques à l'application

## Forensic Mobile

### Protection des fabricants
Les mobiles modernes possèdent de nombreuses protections de sécurité, comme le chiffrement complet des disques, nécessitant une authentification (Mot de passe, Face ID, Empreinte digital ...).

| Mécanisme                                              | Explication                                                                                                                                                                                                                                                                 |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Chiffrement complet du disque et cryptage des fichiers | Sauf si l’appareil est authentifié ou contourné, les outils médico-légaux ne peuvent pas accéder aux données stockées. Les fichiers individuels peuvent également être chiffrés avec des clés distinctes.                                                                   |
| Clés de chiffrement sécurisées                         | Android et iOS utilisent un composant matériel dédié pour stocker les clés de chiffrement, ce qui les rend extrêmement difficiles à extraire, similaire au module TPM sur les cartes mères.                                                                                 |
| Démarrage sécurisé                                     | Assure que seul le code approuvé et signé par le fabricant peut s’exécuter, empêchant toute modification non autorisée. Une ancienne technique d’investigation consistait à utiliser un logiciel de démarrage personnalisé pour contourner certains mécanismes de sécurité. |
| Isolation des applications (Sandboxing)                | Les applications fonctionnent dans des environnements séparés et isolés les unes des autres. Ce concept sera approfondi dans le reste du module.                                                                                                                            |
| Effacement automatique après échec d’authentification  | Les dispositifs peuvent être configurés pour s’effacer après un certain nombre de tentatives d’authentification échouées (ex. PIN incorrects). Cela empêche les attaques par force brute.                                                                                   |
| Effacement à distance                                  | Grâce à des fonctionnalités comme « Find My », les appareils peuvent être effacés à distance en cas de vol ou de perte.                                                                                                                                                     |

## APT vs Mobile

### Logiciels espions
La découverte de Pegasus, un logiciel malveillant très sophistiqué conçu à des fins de surveillance, ayant souvent accès via l'"interaction zéro", était capable de choses telles que:

- Lecture des courriels, accès aux photos
- Lire les messages
- Suivi par GPS
- Enregistrement des appels téléphoniques, du microphone et de la caméra sans aucune connaissance de l'utilisateur
- Obligation de captation
- Ayant très peu de traces de présence

## Acquisition 

### Niveaux d'acquisition

Quand nous parlons d'acquisition on se réfère à la profondeur et à la méthode nécessaire pour extraire les données d'appareils. Les méthodes utilisé sont déterminé par différents facteurs : 

- Age de l'appareil (par exemple version installée du système d'exploitation, mises à jour, etc.)
- Mécanismes de sécurité en place
- Accès authentique ou non authentifié (c'est-à-dire verrouillé ou déverrouillé)
- Disponibilité d'outillage pour l'examinateur
- Profondeur des données que nous souhaitons récupérer (c'est-à-dire les données supprimées)

En Forensic Mobile on a 4 niveaux d'acquisition : 

| Méthode d'acquisition   | Description                                                                                                               | Cas d'utilisation                                                                                                                                                     | Niveau d'accès                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| **Manuel**              | Collecte d’informations en interagissant directement avec l’appareil (ex. parcourir des messages, photographier l’écran). | Utile si l’appareil est déverrouillé, car de nombreux mécanismes de sécurité sont déjà contournés. Soulève toutefois des problèmes d’intégrité et de non-répudiation. | Accès limité aux journaux et bases de données système |
| **Logique**             | Extraction de données via les fonctionnalités du système d’exploitation (API, sauvegardes, etc.).                         | Pertinent quand l’appareil est verrouillé mais peut être authentifié via un autre dispositif de confiance.                                                            | Accès partiel                                         |
| **Système de fichiers** | Copie complète de l’arborescence et des fichiers système/applicatifs.                                                     | Requiert souvent une vulnérabilité, un MDM, un jailbreak/root ou des outils spécialisés pour obtenir un accès privilégié.                                             | Accès effectif                                        |
| **Physique**            | Image bit-à-bit du stockage, incluant les données supprimées.                                                             | Très utile en analyse forensique, surtout pour les anciens appareils. Plus difficile sur les modèles récents à cause du chiffrement et des protections matérielles.   | Accès total (si pas de chiffrement au repos)          |

### Maintien d'accès

Comme absolument tout appareils il est important de garder le dispositif déverrouillé pour avoir le meilleur des scénario une analyse optimal.

Une désactivation du verrouillage automatique peut être un moyen efficace pour que l'appareil reste déverrouillé pendant l'analyse. 

Il peut être également judicieux de mettre le téléphone en mode avion (pour éviter l'altération des données à distance, dans le cadre d'iCloud par exemple) 

### Acquisition logique

Cette méthode est l'une des plus sûre pour garder l'intégrité des données/preuves, car rien est écrasé ou modifié sur le téléphone.

Le problème avec cette méthodes c'est qu'elle ne prend pas les fichiers systèmes par exemple.

Nous pouvons réaliser ce genre d'extraction avec 3uTools, libimobiledevice, adb ... 

Pour un iPhone on peut utiliser ``idevicebackup2``
```Bash
cmnatic@thm-dev$ idevicebackup2 backup --full ./backup  

Started "com.apple.mobilebackup2" service on port 49174. Negotiated Protocol Version 2.1 Starting backup... Backup will be unencrypted. Requesting backup from device... 
Full backup mode. 
[===========================                       ] 55% Finished 
Receiving files 
[==================================================] 100% (12.6 MB/12.5 MB) [==================================================] 100% (12.6 MB/12.5 MB) [==================================================] 100% (12.7 MB/12.5 MB) [==================================================] 100% (12.7 MB/12.5 MB) [==================================================] 100% (12.7 MB/12.5 MB)
```

Pour un Android ``ADB``
```Bash
cmnatic@thm-dev$ adb backup -apk -shared -all -f backup.ab 
 
Backing up data... Please wait. 
Writing android application package (APK) files...  
Writing shared storage files... 
Backup Complete!
```

### Acquisition du système de fichiers
```Bash
cmnatic@thm-dev$ adb pull /data /mnt/android_backup

pull: building file list...
pull: /data/anr/traces.txt -> /mnt/android_backup/anr/traces.txt
pull: /data/system/packages.xml -> /mnt/android_backup/system/packages.xml
pull: /data/system/users/0.xml -> /mnt/android_backup/system/users/0.xml
pull: /data/data/com.android.providers.contacts/databases/contacts2.db -> /mnt/android_backup/data/com.android.providers.contacts/databases/contacts2.db
...
[100%] /data -> /mnt/android_backup
```

## Technique d'acquisition avancé

### Utilitaires spécialisés
Les Spécialiste logiciel et matériel utilise des suites spécialisé comme Cellebrite UFED, qui est une matérielle et logicielle d'exfiltration et d'analyse des données. Il est légalement réservé aux organismes gouvernementaux. 

### Jailbreaking
Le Jailbreak consiste à exploiter une faille connue pour fournir un accès "niveau local", ce qui permet un contrôle COMPLET de l'appareil. Cette technique permet un accès non filtré mais le modifie de manière permanente, donc les preuves, ne serons pas scientifiquement fondé. 

### Custom Boot Loading
Cette technique consiste à faire démarrer l'appareil mobile dans un système d'exploitation temporaire et personnalisé qui fournit un accès de bas niveau à l'appareil et contourne les mécanismes de sécurité. Il diffère des autres, comme Jailbreaking, car il ne modifie pas de façon permanente l'appareil, ce qui le rend scientifiquement rationnel.

### Brute Force
Méthode obsolète car nous avons des temps d'attente bien trop long.



