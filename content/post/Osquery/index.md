+++
author = "Enzo"
title = "Osquery"
date = "2026-06-11"
categories = [
    "Blue Team"
]
tags = [
    "Windows",
    "Linux",
    "Log",
    "Cours"
]
+++

## Introduction

Osquery est un outil open-source qui permet d’explorer et surveiller un système (Linux, macOS, Windows) en utilisant… du SQL.

Il transforme les éléments du système en tables virtuelles :
- fichiers
- processus
- utilisateurs
- connexions réseau
- packages installés
- configurations système

Ensuite, tu peux exécuter des requêtes SQL dessus.

## Installation
Pour installer `Osquery` il nous suffit de nous rendre sur le site : 
[https://pkg.osquery.io/windows/osquery-5.23.0.msi](https://pkg.osquery.io/windows/osquery-5.23.0.msi)

il suffit de le ``.msi`` (pratique que ce soit un `.msi` car plus simple est pousser en GPO), réaliser les étapes basique de l'installation. 

Il s'installera dans : `C:\Program Files\osquery`

## Utilisation

### Requête simple
Nous pouvons faire une requête SQL simple, en sélectionnant TOUT les éléments d'un table et les afficher : 
```SQL
osquery> SELECT * FROM logged_in_users;
+--------+----------------+-----------+---------+------------+-----+-----------------------------------------------+----------------------------------------------------------+
| type   | user           | tty       | host    | time       | pid | sid                                           | registry_hive                                            |
+--------+----------------+-----------+---------+------------+-----+-----------------------------------------------+----------------------------------------------------------+
| active | Administrateur | RDP-Tcp#0 | INF-004 | 1781161429 | -1  | S-1-5-21-4068073117-2498144265-3052310866-500 | HKEY_USERS\S-1-5-21-4068073117-2498144265-3052310866-500 |
+--------+----------------+-----------+---------+------------+-----+-----------------------------------------------+----------------------------------------------------------+
```

Ce genre de requête fonctionne mais sur de grandes tables, ça devient très vite illisible ... 
C'est pour ça que nous pouvons pimper notre commande : 
```SQL
osquery> SELECT type,user,pid,host FROM logged_in_users;
+--------+----------------+-----+---------+
| type   | user           | pid | host    |
+--------+----------------+-----+---------+
| active | Administrateur | -1  | INF-004 |
+--------+----------------+-----+---------+
```
Ici j'ai choisi d'afficher les éléments suivant de la table `logged_in_users` : 
 - type
 - user
 - pid
 - host
Comme nous pouvons le voir, j'ai du changer ma requête en ne sélectionnant pas TOUT les éléments. Ce changement ce fait donc au niveau de l'étoile.
### Jointure entre les tables
Dans certains cas il est nécessaire de faire une jointure entre plusieurs tables. 
L'exemple qui suit prend scénario où nous voulons savoir si un processus a une connexion sur un port local de la machine. Nous devons donc joindre la table processes et listening_ports :
```SQL
osquery> SELECT processes.name, listening_ports.port, processes.pid
    ...> FROM processes
    ...> JOIN listening_ports
    ...> ON processes.pid = listening_ports.pid
    ...> ;
+--------------+-------+------+
| name         | port  | pid  |
+--------------+-------+------+
| svchost.exe  | 135   | 504  |
| System       | 445   | 4    |
| svchost.exe  | 3389  | 7364 |
| System       | 5357  | 4    |
| System       | 5985  | 4    |
| System       | 47001 | 4    |
| lsass.exe    | 49664 | 816  |
| wininit.exe  | 49665 | 656  |
| svchost.exe  | 49666 | 1232 |
| svchost.exe  | 49667 | 1680 |
| spoolsv.exe  | 49668 | 2440 |
| services.exe | 49669 | 800  |
| svchost.exe  | 49840 | 7636 |
| System       | 139   | 4    |
| svchost.exe  | 135   | 504  |
| System       | 445   | 4    |
| svchost.exe  | 3389  | 7364 |
| System       | 5357  | 4    |
| System       | 5985  | 4    |
| System       | 47001 | 4    |
| lsass.exe    | 49664 | 816  |
| wininit.exe  | 49665 | 656  |
| svchost.exe  | 49666 | 1232 |
| svchost.exe  | 49667 | 1680 |
| spoolsv.exe  | 49668 | 2440 |
| services.exe | 49669 | 800  |
| svchost.exe  | 49840 | 7636 |
| svchost.exe  | 123   | 2596 |
| svchost.exe  | 3389  | 7364 |
| svchost.exe  | 3702  | 4232 |
| svchost.exe  | 3702  | 4232 |
| msedge.exe   | 5353  | 7532 |
| msedge.exe   | 5353  | 7532 |
| svchost.exe  | 5353  | 1764 |
| svchost.exe  | 5355  | 1764 |
| svchost.exe  | 52479 | 1764 |
| svchost.exe  | 58740 | 1764 |
| svchost.exe  | 58741 | 4232 |
| System       | 137   | 4    |
| System       | 138   | 4    |
| svchost.exe  | 61030 | 1556 |
| svchost.exe  | 64610 | 2560 |
| svchost.exe  | 123   | 2596 |
| svchost.exe  | 3389  | 7364 |
| svchost.exe  | 3702  | 4232 |
| svchost.exe  | 3702  | 4232 |
| msedge.exe   | 5353  | 7532 |
| svchost.exe  | 5353  | 1764 |
| svchost.exe  | 5355  | 1764 |
| svchost.exe  | 52479 | 1764 |
| svchost.exe  | 58740 | 1764 |
| svchost.exe  | 58742 | 4232 |
+--------------+-------+------+
```