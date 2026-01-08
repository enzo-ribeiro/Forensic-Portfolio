+++
author = "Enzo"
title = "Chall - Active Directory"
date = "2026-01-07"
categories = [
    "Blue Team"
]
tags = [
    "LDAP",
    "NTDS",
    "Forensic",
    "CTF",
    "Chall",
    "Root-Me"
]
+++
## Introduction

Challenge Root-Me


### LDAP - User KerbeRoastable
Lors de vos investigations, vous récupérez une sauvegarde de l’annuaire LDAP de l’entreprise effectuée avec ``ldap2json``. Utilisez les informations présentes dans ce dump pour retrouver l’utilisateur Kerberoastable.

Le flag est l’adresse email de l’utilisateur Kerberoastable.

#### Recherche
Dans cet énoncé nous pouvons voir l'outil utilisé ``ldap2json``. En regardant ce que fais cet outil, nous pouvons voir qu'il est possible d'avoir plus d'info grâce à ce même outil. 

Je l'ai ``git clone`` voici les commandes  : 
````Bash
git clone https://github.com/p0dalirius/ldap2json.git
````

Nous pouvons maintenant commencé notre "exploitation". 
En regardant comment l'outil fonctionne nous pouvons voir que nous avons une option qui nous montre les utilisateurs kerberoastable. 
````Bash 
python3 analysis/analysis.py -f ch31.json 

[>] Loading ch31.json ... done.
[]> help
 - searchbase                          Sets the LDAP search base.
 - object_by_property_name             Search for an object containing a property by name in LDAP.
 - object_by_property_value            Search for an object containing a property by value in LDAP.
 - object_by_dn                        Search for an object by its distinguishedName in LDAP.
 - search_for_kerberoastable_users     Search for users accounts linked to at least one service in LDAP.
 - search_for_asreproastable_users     Search for users with DONT_REQ_PREAUTH parameter set to True in LDAP.
 - help                                Displays this help message.
 - exit                                Exits the script.
````

Donc nous entrons simplement l'option ``search_for_kerberoastable_users`` : 
````Bash
[]> search_for_kerberoastable_users
[CN=Alexandria,CN=Users,DC=ROOTME,DC=local] => servicePrincipalName
 - ['HTTP/SRV-RDS.rootme.local']
````
Nous avons le prénom de l'utilisateur mais pas sont adresse mail ... 
Nous pouvons rechercher les infos qui nous intéresse avec l'option ``object_by_dn CN=Alexandria,CN=Users,DC=ROOTME,DC=local`` : 
````Bash
[]> object_by_dn CN=Alexandria,CN=Users,DC=ROOTME,DC=local
{
    "objectClass": [
        "top",
        "person",
        "organizationalPerson",
        "user"
    ],
    "cn": "Alexandria",
    "sn": "Newton",
    "distinguishedName": "CN=Alexandria,CN=Users,DC=ROOTME,DC=local",
    "instanceType": 4,
    "whenCreated": "2022-08-29 22:26:06",
    "whenChanged": "2022-08-29 22:27:29",
    "displayName": "Alexandria NEWTON",
    "uSNCreated": 26440,
    "uSNChanged": 26451,
    "nTSecurityDescriptor": "..."
    "name": "Alexandria",
    "objectGUID": "{aead746c-2a21-42f8-89bf-2080ec5b2a9f}",
    "userAccountControl": 66048,
    "badPwdCount": 0,
    "codePage": 0,
    "countryCode": 0,
    "badPasswordTime": "1601-01-01 00:00:00",
    "lastLogoff": "1601-01-01 00:00:00",
    "lastLogon": "1601-01-01 00:00:00",
    "pwdLastSet": "2022-08-29 22:26:06",
    "primaryGroupID": 513,
    "objectSid": "S-1-5-21-1356747155-1897123353-4258384033-2092",
    "accountExpires": "9999-12-31 23:59:59",
    "logonCount": 0,
    "sAMAccountName": "a.newton",
    "sAMAccountType": 805306368,
    "servicePrincipalName": [
        "HTTP/SRV-RDS.rootme.local"
    ],
    "objectCategory": "CN=Person,CN=Schema,CN=Configuration,DC=ROOTME,DC=local",
    "dSCorePropagationData": [
        "1601-01-01 00:00:00"
    ],
    "mail": "alexandria.newton@rootme.local"
}
````
Et ici, nous pouvons voir l'adresse mail dans le champs ``mail``. 
Nous avons donc trouvé le flag du challenge. 



### NTDS - Extraction de secrets
Vous avez une sauvegarde des bases de registres et du NTDS d’un serveur Windows hébergeant un Active Directory. Pouvez-vous extraire ses secrets depuis ces fichiers ?

Le flag est la clé aes256-cts-hmac-sha1-96 du compte krbtgt.

#### Recherche
Pour ce challenge nous avons donc des bases de registres et NTDS du serv Windows. 
L'extraction des données se fera avec la suite ``impacket`` et plus précisément avec le script ``secretdump.py`` voici le ``git clone`` du repo de ``impacket`` : 
````Bash
git clone https://github.com/fortra/impacket.git
````
Pour faire plus simple j'ai déposé le fichier dans le repo qui a été cloné. 
Donc, pour récupérer le hash de l'utilisateur il nous faut cette commande : 
````Bash
python3 examples/secretsdump.py -system examples/regbackup/registry/SYSTEM -ntds examples/regbackup/Active\ Directory/NTDS.dit LOCAL | grep krbtgt:aes256-cts-hmac-sha1-96

krbtgt:aes256-cts-hmac-sha1-96:85c422e6d4f4e340b445c6a3f16d8d7b25bfdf290d956134bc0d5b6ab272b475
````
Voici l'explication de cette commande : 
* ``-system`` : Déclare la "ruche" SYSTEM du dump. 
* ``-ntds`` : Décalre le fichier NTDS.dit qui nous intéresse
Le grep n'est pas nécessaire mais il est très utile car il y a beaucoup d'utilisateur. 

Nous avons donc trouvé le flag de ce challenge. 


### LDAP - User ASRepRoastable
Lors de vos investigations, vous récupérez une sauvegarde de l’annuaire LDAP de l’entreprise effectuée avec ldap2json. Utilisez les informations présentes dans ce fichier pour retrouver l’utilisateur ASRepRoastable.

Le flag est l’adresse email de l’utilisateur ASRepRoastable

#### Recherche
Pour ce challenge nous n'allons pas réinventé la roue, nous allons reproduire la même stratégie que le premier challenge. 
Nous listons les utilisateurs ``asreproastable`` avec : 
````Bash
[]> search_for_asreproastable_users
[CN=Fitzgerald,CN=Users,DC=ROOTME,DC=local] => userAccountControl
 - 4260352
````
Puis nous listons les infos nécessaire à ce chall (même commande que pour le premier chall) : 
````Bash
[]> object_by_dn CN=Fitzgerald,CN=Users,DC=ROOTME,DC=local
{
    "objectClass": [
        "top",
        "person",
        "organizationalPerson",
        "user"
    ],
    "cn": "Fitzgerald",
    "sn": "Landry",
    "distinguishedName": "CN=Fitzgerald,CN=Users,DC=ROOTME,DC=local",
    "instanceType": 4,
    "whenCreated": "2022-08-30 03:44:38",
    "whenChanged": "2022-08-30 03:53:26",
    "displayName": "Fitzgerald LANDRY",
    "uSNCreated": 26037,
    "uSNChanged": 30985,
    "nTSecurityDescriptor": "..."
    "name": "Fitzgerald",
    "objectGUID": "{f3c1fa29-268a-4092-b183-bbe6c837ad79}",
    "userAccountControl": 4260352,
    "badPwdCount": 0,
    "codePage": 0,
    "countryCode": 0,
    "badPasswordTime": "1601-01-01 00:00:00",
    "lastLogoff": "1601-01-01 00:00:00",
    "lastLogon": "1601-01-01 00:00:00",
    "pwdLastSet": "2022-08-30 03:44:38",
    "primaryGroupID": 513,
    "objectSid": "S-1-5-21-1356747155-1897123353-4258384033-2027",
    "accountExpires": "9999-12-31 23:59:59",
    "logonCount": 0,
    "sAMAccountName": "flandry",
    "sAMAccountType": 805306368,
    "objectCategory": "CN=Person,CN=Schema,CN=Configuration,DC=ROOTME,DC=local",
    "dSCorePropagationData": [
        "1601-01-01 00:00:00"
    ],
    "msDS-SupportedEncryptionTypes": 0,
    "mail": "fitzgerald.landry@rootme.local"
}
````
Comme pour le premier chall, nous pouvons trouver l'adresse mail nécessaire dans le champs ``mail``. 
