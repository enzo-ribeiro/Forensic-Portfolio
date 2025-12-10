+++
author = "Enzo"
title = "Mobile - Analyse iOS"
date = "2025-12-09"
categories = [
    "Mobile"
]
tags = [
    "iOS",
    "Mobile",
    "Forensic",
    "Analyse"
]
+++

## Introduction

Depuis 2018, Apple impose un certificat de confiance, ce qui restreint l'accès des appareils vers les iPhone. Cette fonctionnalité permet de désactivé/activé l'entré/la sortie des données de l'iPhone.

Une fois le certificat validé par les deux appareils, nous pouvons le trouver (sur Windows dans le chemin ci-dessous) : 
`C:\ProgramData\Apple\Lockdow`
![](5de96d9ca744773ea7ef8c00-1718720183945.png)

### Info à savoir
Ce certificat est valable pendant 30 jours.
Il contient des identifiants unique du téléphone.
Il est stocké sur l'iPhone et sur le PC.

### Bloqué & Débloqué

Lorsqu’un iPhone est protégé par un mécanisme d’authentification (Face ID, Touch ID ou code d’accès), l’appareil active automatiquement les protections associées à l’état **« verrouillé »**.  
Ces méthodes d’authentification ne se limitent pas à empêcher un tiers d’accéder à l’appareil : elles renforcent également la sécurité en arrière-plan grâce à plusieurs mécanismes supplémentaires.

Le tableau ci-dessous présente un aperçu des protections disponibles lorsque l’iPhone est dans cet état.

| **Protection**             | **Explication**                                                                                                                                                                                         |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Chiffrement du fichier     | Tous les fichiers sur l'iPhone sont cryptés au repos. L'authentification doit pouvoir lire les données dans les fichiers.                                                                               |
| Accessibilité des fichiers | Fichiers avec le `NSFileProtectionComplete`la classe de protection des données et les autres sont inaccessibles. Seuls les fichiers marqués de la `NSFileProtectionNone`sont accessibles dans cet état. |
| Accès matériel             | Par défaut, l'accès à des composants matériels "sensibles" tels que le microphone, la caméra, etc., les nouveaux appariements Bluetooth sont refusés.                                                   |
| Accès aux applications     | Les fonctions d'application qui s'exécutent en arrière-plan (i.e. La musique, les cartes "témoillaire", etc.) ne sont autorisées à circuler que dans cet état.                                          |
| Accès à la chaîne de clés  | Le porte-clés iOS (c'est-à-dire les mots de passe stockés) n'est accessible qu'après que l'appareil est entré dans l'état "Débloqué".                                                                   |
| Confiance et appariement   | La mise en place de l'iPhone dans des appareils pour lesquels il n'existe pas de certificat de confiance nécessite l'authentification de l'utilisateur.                                                 |

### Classes de protection des données
iOS fait une étape supplémentaire en matière de sécurité en introduisant des Classes de Protection des Données. Ces classes sont des politiques appliquées aux dossiers qui déterminent:
- Lorsque le fichier peut être lu ou écrit
- Lorsque la clé de chiffrement devient disponible pour déverrouiller le fichier

Le tableau ci-dessous résume les quatre classes primaires de protection des données.

| **Classe de protection des données**             | **Exemple**                                                                                                                            | **État requis**                                                                                                                                     |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| NSFileProtectionNone                             | Cache.                                                                                                                                 | Aucune - toujours accessible.                                                                                                                       |
| NSFileProtectionComplète UnlessOpen              | Des applications qui jouent de l'audio et de la vidéo, permettant aux médias de diffuser en continu lorsque l'appareil est verrouillé. | Exige que le fichier soit ouvert en déverrouillé, mais reste accessible après verrouillage de l'appareil.                                           |
| NSFileProtectionCompleteUntilFirstAuthentication | Lecture et écriture des données en arrière-plan (par exemple, nombre d'étapes, notifications).                                         | Le dispositif doit être déverrouillé une fois après le démarrage, mais le fichier reste accessible même après qu'il soit verrouillé ultérieurement. |
| NSFileProtectionComplete                         | Domimtiques, messages, données sanitaires.                                                                                             | Exige que l'appareil soit déverrouillé.                                                                                                             |

## Préservation des preuve
Sur un iPhone il y a plusieurs manières de supprimer des preuves à distance (comme la fonctionnalité supprimer cet appareil dans l'application ``Find My``. Ces méthodes sont présente pour ne pas donné d'information personnel en cas de vol. 

Pour ce protéger de la suppression d'un appareil à distance nous pouvons le placer dans une cage de faraday (ou un sac de faraday). 

## Système de fichier
Sur un iPhone disposant d'un système ultérieur à 10.3 (2017), le système de fichier sera APFS. Si le système est antérieur à 10.3, le système de fichier sera HFS. 

A savoir sur HFS : 
 - n'est pas chiffré
 - n'a pas de checksum 

A savoir sur APFS : 
- Chiffrement complet du disque
- Une gestion plus intelligente des données
- Utilise la structure de partition GPT
- A un checksum
- Et de nombreux mécanismes de protection contre les accidents (tels que la protection des métadonnées)

Pour information, les applications installé sur un iPhone n'as pas un accès direct au système de fichier. Elles s'exécutent dans une sandbox avec un système de fichier "virtuel" que seul l'app peut voir.  

| **Domaine** | **Description**                                                                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Données     | Stocke les données d'application, les paramètres et les fichiers d'utilisateurs.                                                                                    |
| Cache       | Stocke des fichiers temporaires tels que des fichiers mis en cache à partir du navigateur web.                                                                      |
| Système     | Ce domaine stocke des fichiers essentiels liés au système d'exploitation. Normalement, il est en lecture seule pour protéger la sécurité du système d'exploitation. |
| Partage     | Ce domaine permet de partager les données provenant d'applications réalisées par le même développeur (groupe d'applications).                                       |
### Répertoire
| Répertoire                       | Contexte    | Description                                                                                                                                                                                                                                                      |
| -------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| /System/Bibliothèque/            | Système     | Les données qui sont essentielles pour le système d'exploitation iOS (telles que les polices, les cadres système, les composants d'interfaces utilisateur, etc.) sont stockées ici.                                                                              |
| /tmp/                            | Système     | Les fichiers temporaires relatifs au fonctionnement normal de l'iPhone sont stockés ici. Il s'agit notamment des téléchargements en cours, des journaux, des vidanges de crash, des caches, etc.                                                                 |
| /System/Applications/            | Système     | Ce répertoire est l'endroit où sont stockées les données pour des applications système pré-installées telles que Weather, Clock, Wallet, etc.                                                                                                                    |
| /Conteneurs/Données/Application/ | Utilisateur | Des applications non par défaut telles que celles de l'App Store sont stockées ici. Il est important de noter que, en raison du bac à sable, les applications ne peuvent pas accéder aux données d'une autre application. Le bac à sable est expliqué plus loin. |
| /Médies/                         | Utilisateur | Des médias tels que des photos et des vidéos du rouleau de la caméra (y compris des métadonnées), ainsi que des enregistrements audio et des livres électroniques sont stockés ici.                                                                              |
| /Bibliothèque/                   | Utilisateur | Les données d'application telles que le carnet d'adresses, le calendrier, les SMS, le téléphone, les préférences, le safari, etc., sont stockées ici.                                                                                                            |
| /Documents/                      | Utilisateur | Les fichiers téléchargés ou les fichiers créés par l'utilisateur sont stockés ici. Par exemple, les fichiers PDF, MP4/MP3, les téléchargements de Safari, etc.                                                                                                   |

### Type de fichiers 
La majorité des fichiers que nous trouverons serions au format Plists, XML et SQLites.

## Artefacts
Nous allons voir où se trouve les différentes information importante : 
 - Contacts : `/HomeDomain/Library/AddressBook` SQLite
 - Photos : `/CameraRollDomain/Media/DCIM` (HEIC)
 - Calendrier : `/HomeDomain/Library/Calendar` SQLite
 - WiFi : `/SystemPreferencesDomain` (Plists)
 - Navigateur : `/HomeDomain/Library/Safari`

### Répertoire
 - ``/var/mobile`` : 

| **Données**              | **Description**                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| Documents                | Fichiers créés soit par l'utilisateur, soit par l'application (sauvegarder des fichiers, fichiers PDF sauvegardés, etc.). |
| Bibliothèque             | Configuration et fichiers cache pour l'OS.                                                                                |
| Tmp                      | Dossiers temporaires habituellement utilisés par les demandes.                                                            |
| Données de l'utilisateur | Téléchargements d'utilisateurs ainsi que photos, vidéos et autres médias.                                                 |
 - ``/var/keychains`` : 

| **Données**                | **Description**                                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Mots de passe              | Ce répertoire stocke des informations d'identification sauvegardées (pour les sites web, etc.) connues sous le nom d'Apple. |
| Certificats                | Cet annuaire stocke des certificats SSL/TLS pour des applications web, des VPN, etc.                                        |
| Clés de cryptage et jetons | Cet annuaire stocke diverses clés publiques ainsi que des jetons OAuth et autres.                                           |
 - ``/var/logs`` :

| **Données**                | **Description**                                                                                                                                                                                                                  |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Logements de réseau        | Ces types de logs se rapportent aux performances et aux événements du système, ainsi qu'à un enregistrement des événements déclenchés par le noyau.                                                                              |
| Loges d'application        | Les applications stockent leurs journaux dans ce répertoire. Il peut s'agir de traces de cheminées et d'informations de débogage en cas d'accident d'application.                                                                |
| Débogage                   | Ces types de journaux conservent des informations sur les événements du système qui peuvent être utilisés dans le débogage, tels que l'activité réseau, les applications en cours d'exécution et une chronologie des événements. |
| Actualisation des journaux | Ces journaux contiennent des informations spécifiquement pour les mises à jour, c'est-à-dire la vérification des mises à jour et le stockage des informations lors de la mise à jour de l'iPhone.                                |
 - ``/var/db`` : 

| **Données**                    | **Description**                                                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bases de données de systèmes   | Des informations telles que les contacts, les messages et les entrées de calendrier sont stockées dans ces bases de données.                            |
| Bases de données d'application | Les applications stockent leurs données dans ces bases de données, telles que la progression du jeu, une liste de contacts, de boîtes aux lettres, etc. |
| Métadonnées                    | Les informations relatives aux métadonnées pour les médias (photos, vidéos) sont stockées ici, telles que le temps nécessaire, l'emplacement, etc.      |

## Analyse
Pour l'analyse nous avons plusieurs outils. La librairie ``libimobiledevice``, outil en CLI qui s'utilise comme montré ci-dessous : 
```Bash
> ideviceinfo

ActivationState: Activated
ActivationStateAcknowledged: true
ChipSerialNo: 00EAaUAXXXXXXX
DeviceClass: iPhone
DeviceColor: 1
DeviceName: iPhone
PasswordProtected: false
PhoneNumber: +44 REDACTED
PkHash: Hz9b38WSRXREDACTED
ProductName: iPhone OS
ProductType: iPhone10,5
ProductVersion: 14.6
``` 

La sauvegarde se fait avec la commande suivante : 
`
```Bash
idevicebackup2 backup --full ./backup
```

Nous pouvons utiliser un outil en GUI, 3uTools.

Pour l'analyse existe un outil du nom de iLEAPP (la version apple de a LEAPP).

## Pratique

J'ai un dump d'un téléphone. On me demande de trouver sur quel réseau Wi-Fi il est connecté : 
Sur la machine que nous possédons, nous avons un .exe qui se nomme strings64.exe pour nous aider à trouver les flags nécessaire.
```MsDOS
strings64.exe com.apple.wifi.known-networks.plist
bplist00
"Sm_
wifi.network.ssid.Wifi Extra_
wifi.network.ssid.OneMinuteStaff_
wifi.network.ssid. Wifi Extra_
wifi.network.ssid.Wifi+
 !YAddReasonVHiddenZEAPProfile_
PasspointSPRoamingEnabledYUpdatedAtTSSIDWAddedAt^__OSSpecific___
SupportedSecurityTypes[PayloadUUID^Carrier Bundle
^AcceptEAPTypes
JWifi Extra3A
WAP_MODE_
%DisableWiFiAutoJoinUntilFirstUserJoin
WPA/WPA2 Enterprise_
$BBDC8872-781A-4DF4-AAB8-E8C91F549B7B
#$%&'()*+,-
012MNORYAddReasonVHidden[LowDataModeTSSIDWAddedAt^__OSSpecific__^JoinedByUserAt_
SupportedSecurityTypes^CaptiveProfileYUpdatedAt]WiFi Settings
KBens Iphone3A
3456789:
<@C
WiFiNetworkAttributeIsMoving_
 BEACON_PROBE_INFO_PER_BSSID_LISTUBSSID_
networkKnownBSSListKey_
$WiFiNetworkAttributeProminentDisplayWCHANNEL_
#WiFiNetworkPasswordModificationDateWAP_MODE
5>?@
OTA_SYSTEM_INFO_SENT_
 OTA_SYSTEM_INFO_BEACON_ONLY_SENT_
e2:89:ce:37:cf:a6
EF85GHIJ]CHANNEL_FLAGSZlastRoamed
e2:89:ce:37:cf:a6
]WPA2 Personal
^CaptiveNetwork
TUVWXYZ[\]^
defgklYAddReasonVHiddenZEAPProfile_
PasspointSPRoamingEnabledYUpdatedAtTSSIDWAddedAt^__OSSpecific___
SupportedSecurityTypes[PayloadUUID^Carrier Bundle
ab^AcceptEAPTypes
K Wifi Extra3A
WAP_MODE_
%DisableWiFiAutoJoinUntilFirstUserJoin
WPA/WPA2 Enterprise_
$9F1520B9-4397-4E78-86BB-5FA33CD958EC
nopqrstuvwx
YAddReasonVHiddenZEAPProfile_
PasspointSPRoamingEnabledYUpdatedAtTSSIDWAddedAt^__OSSpecific___
SupportedSecurityTypes[PayloadUUID^Carrier Bundle
{|^AcceptEAPTypes
EWifi+3A
WAP_MODE_
%DisableWiFiAutoJoinUntilFirstUserJoin
WPA/WPA2 Enterprise_
$AB504232-98FF-4BDC-B68D-8203C4358A6E
0Pp
```

Ici 4 SSID ressortes grâce au préfixe ``wifi.network.ssid.``. Celui qui nous intéresse est ``OneMinuteStaff``

```
Q : What is the name (SSID) of the Wi-Fi network the iPhone connected to?

A : OneMinuteStaff
```

Ensuite, on nous demande de qui est notre principal concurrent enregistré dans nos contacts. 
On se rend dans l'AdressBook Grâce à SQLite. et on voir qu'une seule personne qui travaille dans la même société que nous ``Wayne Garcey``. 

```txt
Q : What are the saved contact details for the competitor? 
Answer format: Firstname,Lastname

A : Wayne,Garcey
```

Pour finir on nous demande de retrouver la date de l'échange.
Dans la base Calendar.sqlite.db nous avons une table CalendarItem, si on va dessus et que nous cherchons dans ma colonne id `1` nous pouvons tomber sur la date du `30/03/2024`
```txt
Q : On what day was the exchange of information to take place?
Answer format: DD/MM/YYYY


A : 30/03/2024
```