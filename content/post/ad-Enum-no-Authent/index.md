+++
author = "Enzo"
title = "AD - Enumération sans authentification"
date = "2026-03-26"
categories = [
    "Red Team"
]
tags = [
    "Windows",
    "AD",
    "Enumeration",
    "CTF",
    "Cours"
]
+++
# AD : Enumération sans identifiant

## Host Discovery
Vu que nous n'avons pas d'information concernant le réseau nous devons le scanner afin de découvrir ce que nous avons à notre disposition, pour cela, nous pouvons utiliser ``Nmap`` : 
````Bash
nmap -sn 10.211.11.0/24
Nmap scan report for 10.211.11.10
Host is up (0.019s latency).
Nmap scan report for 10.211.11.20
Host is up (0.018s latency).
Nmap scan report for 10.211.11.250
Host is up (0.020s latency).
````
- `-sn` : simple ping pour savoir quel host est ``up``
## Port AD
Pour détecter un AD sur le réseau nous pouvons tester les port suivants : 
| Port  | Protocole       | 
|-------|-----------------|
| 88    | Kerberos        |
| 135   | MS-RPC          |
| 139   | SMB/NetBIOS     |
| 389   | LDAP            | 
| 445   | SMB             |
| 464   | Kerberos (kpasswd) |

Pour ça nous pouvons à nouveau utiliser ``nmap`` avec la commande suivante : 
````Bash
nmap -p 88,135,139,389,445 -sV -sC -iL hosts.txt
````
- ``-sV`` : Active la détection de version
- ``-sC`` : Lancement des script basique de nmap (NSE)  
- ``-iL hosts.txt`` : Va tester les IPs présentes dans le fichier "hosts.txt"

Pour rediriger la sortie de cette commande nous pouvons utiliser l'argument `-oN` suivi du nom du fichier de redirection ce qui donne la commande suivante : 
````Bash
nmap -p 88,135,139,389,445 -sV -sC -iL hosts.txt -oN out-nmap.txt
````

## Enumération SMB
Si dans notre précédent scan nous voyons les ports `139`, `445` ouvert, il y a probablement un serveur SMB sur la machine. 
Nous pouvons donc essayer le voir quels partage sont préseant avec la commande suivante : 
````Bash
smbclient -L //10.211.11.10 -N
````
- ``-L`` : Liste le partage
- ``//10.211.11.10`` : IP qui nous intéresse 
- ``-N`` : Sans mot de passe

Nous pourrons y voir les partages présent, voici un exemple de sortie de commande (exemple tiré de la room ``adbasicenumeration`` de TryHackMe, room ou je suis actuellement pour écrire ce poste) : 
````Bash
smbclient -L //10.211.11.10 -N
Anonymous login successful

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        AnonShare       Disk      
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        SharedFiles     Disk      
        SYSVOL          Disk      Logon server share 
        UserBackups     Disk 
````

Pour lister et exploiter des partages SMB nous pouvons également utiliser des outils comme ``smbmap`` ou encore ``enum4linux``. 


## Enumération LDAP
### ldapsearch
Voici un exemple d'utilisation : 
````Bash
ldapsearch -x -H ldap://10.211.11.10 -s base
````
- ``-x`` : Aunthentification simple, ici en anonyme
- ``-H`` : Donne le serveur LDAP
- ``-s`` : Donne la limite des requête, ici base = pas de sous-arbres ou d'objet enfant

Voici l'utilisation et le résultat de cette commande : 
````Bash 
ldapsearch -x -H ldap://10.211.11.10 -s base

dn:
domainFunctionality: 6
forestFunctionality: 6
domainControllerFunctionality: 7
rootDomainNamingContext: DC=tryhackme,DC=loc
ldapServiceName: tryhackme.loc:dc$@TRYHACKME.LOC
isGlobalCatalogReady: TRUE
supportedSASLMechanisms: GSSAPI
supportedSASLMechanisms: GSS-SPNEGO
supportedSASLMechanisms: EXTERNAL
supportedSASLMechanisms: DIGEST-MD5
supportedLDAPVersion: 3
supportedLDAPVersion: 2
[...]
````

Pour avoir des informations sur les utilisateurs nous pouvons utiliser la commance : 

````Bash
ldapsearch -x -H ldap://10.211.11.10 -b "dc=tryhackme,dc=loc" "(objectClass=person)"
````

for i in $(seq 500 2000); do echo "queryuser $i" |rpcclient -U "" -N 10.211.11.10 2>/dev/null | grep -i "User Name"; done

### enum4linux-ng
Voici l'utilisation de cet outil : 
````Bash
enum4linux-ng -A 10.211.11.10 -oA results.txt
````
- `-A` : Enumération de tout ce qui est possible
- `-oA results.txt` : Met le résultat de la commande dans le fichier "results.txt"

Cet outil nous donne énormément d'infos, il va lister les utilisateurs, les groupes, les informations systèmes de l'AD, les partages SMB ... 

## Enumération DNS 

Pour voir qui fais office de serveur DNS sur le réseau, nous pouvons lancer l'outil ``nmap`` avec les arguments suivants : 
- ``--scrip dns-srv-enum`` 
- ``--script-args dns-srv-enum.domain="<DOMAIN>"``

Ce qui donne la commande suivante : 
````Bash
nmap --script dns-srv-enum --script-args dns-srv-enum.domain="TRYHACKME.LOC"
````

Toujours avec l'outil ``nmap`` nous pouvons simplement scanner tout le réseau sur le port `53` en ``TCP`` et ``UDP`` avec les commandes suivante : 
````Bash
nmap -sV -p 53 "10.211.11.0/24"
nmap -sV -sU -p 53 "10.211.11.0/24"
````
- ``-sV`` : Active la détection de version
- ``-sU`` : Déclare le protocole ``UDP``


