+++
author = "Enzo"
title = "Chall - Cobalt Strike"
date = "2025-12-28"
categories = [
    "Blue Team"
]
tags = [
    "Windows",
    "Forensic",
    "CTF",
    "Chall",
    "Volatility"
]
+++

## Introdution
Je suis alternant à l'ESGI et en intervenant j'ai Christopher THIEFIN (Processus Thief) qui a donné plusieurs cours à ma promo. Un des cours donnés est la Forensique Numérique, nous avons donc eu ce challenge à résoudre. 

Le but est de retrouver certaines informations sur une capture mémoire d'un poste infecté. 

## Consigne
- Identifier le binaire malveillant téléchargé dans un répertoire temporaire,
- Identifier le hash NT de l'administrateur,
- Identifier l'adresse IP probable de l'attaquant

## Recherche 
Tout d'abord nous devons installer volatility. Il y a pas mal de tutos sur internet pour ça, je vous laisse checker tout ça. 

De mon côté, à l'installation j'ai préféré faire un alias pour m'éviter les commandes à rallonge avec les chemins absolut. 
```Bash
# VOLATILITY
alias vol='python3 /Users/enzo/volatility3/vol.py'
```

La capture mémoire est au nom de ``cobalt_strike_hta.raw``

### Binaire Malveillant
Pour trouver le binaire malveillant nous devons scanner les différents processus en cours durant la capture : 
```
vol -f cobalt_strike_hta.raw windows.psscan.PsScan   
```
Cette commande nous renvoie tout les processus mais un seul nous inrtéresse : 
```
2232    988     evil.exe        0x1f65fb30      10      248     1       True    2023-01-01 19:21:58.000000 UTC  N/A     Disabled
```
Nous avons donc la première étape.

### NT Hash
Pour récupérer les hash NT des utilisateurs nous avons un plugins intégré : 
````Bash
vol -h
    windows.hashdump.Hashdump
                        Dumps user hashes from memory
````
En applications ça nous donne ça : 
````Bash
vol -f cobalt_strike_hta.raw windows.hashdump.Hashdump 
Volatility 3 Framework 2.27.0

Administrateur  500     aad3b435b51404eeaad3b435b51404ee        8758304b6af01bb8ce1691495d29cb61
Invité  501     aad3b435b51404eeaad3b435b51404ee        31d6cfe0d16ae931b73c59d7e0c089c0
POC-USER        1000    aad3b435b51404eeaad3b435b51404ee        8758304b6af01bb8ce1691495d29cb61
````
Nous avons maintenant les hash NT des utilisateurs du poste infecté. 

#### Pour le fun
Nous pouvons nous rendre sur CrackStation pour avoir le hash en claire : 

| Hash | Type | Result|
|:-------- |:--------:| --------:|
| 8758304b6af01bb8ce1691495d29cb61     | NTLM   | spiderman    |


### IP de l'attanquant
Pour trouver les connexions réseau nous avons un autre plugin ``windows.netscan.NetScan``. 
Voici ce que donne le plugin sur la capture mémoire. 

```` Bash
vol -f cobalt_strike_hta.raw windows.netscan.NetScan
Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
Offset  Proto   LocalAddr       LocalPort       ForeignAddr     ForeignPort     State   PID     Owner   Created

0x47f8010       TCPv4   -       49172   172.19.63.255   1337    CLOSED  324     taskmgr.exe     N/A
0xa8d0010       TCPv4   -       49172   172.19.63.255   1337    CLOSED  324     taskmgr.exe     N/A
0x1e4372c0      UDPv6   fe80::8dfc:d689:b527:b151       49726   *       0               1308    svchost.exe     2023-01-01 17:29:12.000000 UTC
0x1e4430e0      TCPv4   0.0.0.0 49158   0.0.0.0 0       LISTENING       512     lsass.exe       -
0x1e463010      UDPv6   ::1     49727   *       0               1308    svchost.exe     2023-01-01 17:29:12.000000 UTC
...
````
Pour éviter de faire tout les processus qui ont une connexion externe nous pouvons filtrer la sortie avec un grep : 
````Bash
vol -f cobalt_strike_hta.raw windows.netscan.NetScan | grep evil
0x1fc92a80 100.0TCPv4   172.19.59.55scan49239fin51.38.35.62     8182    CLOSED  2232    evil.exe        -
````
Et voilà nous avons le dernier ``flag``