+++
author = "Enzo"
title = "Chall - FCSC Pour commencer"
date = "2026-02-05"
categories = [
    "Blue Team"
]
tags = [
    "Forensic",
    "CTF",
    "Chall",
    "FCSC",
    "Mémoire",
    "Volatilit",
    "Windows"
]
+++

## Introduction 1 

Vous vous préparez à analyser une capture mémoire et vous notez quelques informations sur la machine avant de plonger dans l’analyse :

    nom d’utilisateur,
    nom de la machine,
    adresse IPv4, non locale, de la machine.

Le flag est au format ``FCSC{<nom d'utilisateur>:<nom de la machine>:<adresse IPv4>}`` où :

    <nom d'utilisateur> est le nom de l’utilisateur qui utilise la machine,
    <nom de la machine> est le nom de la machine analysée et
    <adresse IPv4> est l’adresse IPv4, non locale, de la machine.

Par exemple : FCSC{Arthur:Ordinateur-de-rct:192.168.1.150}.

## Recherche
Pour réaliser ce chall nous utiliserons volatility3. 
Une fois de ``.tar.gz`` téléchargé et extrait, nous pouvons commencer la recherche.

### Utilisateurs

Pour connaître les noms d'utilisateur présents sur la machine nous pouvons utiliser le plugin ``hashdump`` de vol. 
````Bash
vol -f analyse-memoire.dmp windows.hashdump.Hashdump

Volatility 3 Framework 2.27.0
/Users/enzo/volatility3/volatility3/framework/deprecation.py:28: FutureWarning: This API (volatility3.plugins.windows.registry.hashdump.Hashdump.run) will be removed in the first release after 2026-09-25. This plugin has been renamed, please call volatility3.plugins.windows.registry.hashdump.Hashdump rather than volatility3.plugins.windows.hashdump.Hashdump.
  warnings.warn(

User    rid     lmhash  nthash
/Users/enzo/volatility3/volatility3/framework/deprecation.py:105: FutureWarning: This plugin (volatility3.plugins.windows.hashdump.Hashdump) has been renamed and will be removed in the first release after 2026-09-25. Please ensure all method calls to this plugin are replaced with calls to volatility3.plugins.windows.registry.hashdump.Hashdump
  warnings.warn(

Administrateur  500     aad3b435b51404eeaad3b435b51404ee        31d6cfe0d16ae931b73c59d7e0c089c0
Invité  501     aad3b435b51404eeaad3b435b51404ee        31d6cfe0d16ae931b73c59d7e0c089c0
DefaultAccount  503     aad3b435b51404eeaad3b435b51404ee        31d6cfe0d16ae931b73c59d7e0c089c0
WDAGUtilityAccount      504     aad3b435b51404eeaad3b435b51404ee        f3ae0fa4a6f8774079f9316acc07eaee
userfcsc-10     1001    aad3b435b51404eeaad3b435b51404ee        3f2360db87910bf0120f8de2b2a0807b
````

Ici on voit un nom d'utilisateur qui paraît plus logique, on devine que c'est cet utilisateur qui utilise le poste. 
On a le début du flag ``FCSC{userfcsc-10:xx:xx}``.

### Nom du poste

Pour obtenir le nom du poste, nous pouvons utiliser le plugin ``sessions``. 
````Bash
vol -f analyse-memoire.dmp windows.sessions.Sessions
Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
Session ID      Session Type    Process ID      Process User Name       Create Time

N/A     -       4       System  -       2025-04-01 22:10:38.000000 UTC
N/A     -       124     Registry        -       2025-04-01 22:10:34.000000 UTC
N/A     -       452     smss.exe        -       2025-04-01 22:10:38.000000 UTC
0       -       556     csrss.exe       /SYSTEM 2025-04-01 22:10:43.000000 UTC
0       -       656     wininit.exe     /SYSTEM 2025-04-01 22:10:43.000000 UTC
0       -       800     services.exe    /SYSTEM 2025-04-01 22:10:43.000000 UTC
0       -       824     lsass.exe       /SYSTEM 2025-04-01 22:10:43.000000 UTC
0       -       936     svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:44.000000 UTC
0       -       960     fontdrvhost.ex  Font Driver Host/UMFD-0 2025-04-01 22:10:44.000000 UTC
0       -       508     svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:44.000000 UTC
0       -       648     svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:44.000000 UTC
0       -       1040    svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:44.000000 UTC
0       -       1060    svchost.exe     AUTORITE NT/SERVICE LOCAL       2025-04-01 22:10:44.000000 UTC
0       -       1168    svchost.exe     AUTORITE NT/SERVICE LOCAL       2025-04-01 22:10:44.000000 UTC
0       -       1196    svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:45.000000 UTC
0       -       1220    svchost.exe     AUTORITE NT/SERVICE LOCAL       2025-04-01 22:10:45.000000 UTC
0       -       1348    svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:45.000000 UTC
0       -       1356    svchost.exe     AUTORITE NT/SERVICE LOCAL       2025-04-01 22:10:45.000000 UTC
0       -       1404    svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:45.000000 UTC
0       -       1484    svchost.exe     AUTORITE NT/SERVICE LOCAL       2025-04-01 22:10:45.000000 UTC
0       -       1516    svchost.exe     WORKGROUP/DESKTOP-JV996VQ$      2025-04-01 22:10:45.000000 UTC
````

Donc, nous pouvons plusieurs fois, le workgroup suivi du nom du PC. Ici c'est ``DESKTOP-JV996VQ``. 

On a la suite du flag ``FCSC{userfcsc-10:DESKTOP-JV996VQ:xx}``.

### IP du poste

Pour trouver l'IP de la machine nous pouvons utiliser le plugin ``netscan``. 

````Bash
vol -f analyse-memoire.dmp windows.netscan.NetScan
Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
Offset  Proto   LocalAddr       LocalPort       ForeignAddr     ForeignPort     State   PID     Owner   Created

0xa50a206ba8a0  TCPv4   10.0.2.15       65480   185.231.164.136 443     CLOSED  7232    msedge.exe      2025-04-01 22:14:07.000000 UTC
0xa50a20a31910  TCPv4   0.0.0.0 7680    0.0.0.0 0       LISTENING       9112    svchost.exe     2025-04-01 22:12:52.000000 UTC
0xa50a20a31910  TCPv6   ::      7680    ::      0       LISTENING       9112    svchost.exe     2025-04-01 22:12:52.000000 UTC
0xa50a20b39010  TCPv4   10.0.2.15       49701   13.107.246.254  443     CLOSE_WAIT      6720    SearchApp.exe   2025-04-01 22:11:02.000000 UTC
0xa50a20e66a20  TCPv4   10.0.2.15       51497   150.171.28.12   443     CLOSED  7232    msedge.exe      2025-04-01 22:13:43.000000 UTC
0xa50a20ef5a90  TCPv4   10.0.2.15       59260   13.107.138.254  443     CLOSED  6720    SearchApp.exe   2025-04-01 22:15:17.000000 UTC
0xa50a240688a0  TCPv4   10.0.2.15       62866   204.79.197.219  443     CLOSED  7232    msedge.exe      2025-04-01 22:13:52.000000 UTC
0xa50a25b5e310  TCPv4   0.0.0.0 49665   0.0.0.0 0       LISTENING       656     wininit.exe     2025-04-01 22:10:44.000000 UTC
0xa50a25b5e310  TCPv6   ::      49665   ::      0       LISTENING       656     wininit.exe     2025-04-01 22:10:44.000000 UTC
0xa50a25b5e5d0  TCPv4   10.0.2.15       139     0.0.0.0 0       LISTENING       4       System  2025-04-01 22:10:45.000000 UTC
0xa50a25b5e890  TCPv4   0.0.0.0 49664   0.0.0.0 0       LISTENING       824     lsass.exe       2025-04-01 22:10:44.000000 UTC
0xa50a25b5e890  TCPv6   ::      49664   ::      0       LISTENING       824     lsass.exe       2025-04-01 22:10:44.000000 UTC
````

Dans la colonne ``LocalAddr`` nous pour voir l'IP du poste (celle qui nous intéresse), ``10.0.2.15``. 

Nous avons donc tout le flag ``FCSC{userfcsc-10:DESKTOP-JV996VQ:10.0.2.15}``. 

## Introduction 2

La capture mémoire a été réalisée pendant qu’un utilisateur était en train de travailler sur un document hautement sensible. Si une compromission du poste a eu lieu, ce document a peut-être été volé. Pouvez-vous retrouver :

    le nom du logiciel d’édition du document,
    le nom du document.

Le flag est au format ``FCSC{<nom du logiciel>:<nom du document>}`` où :

    <nom du logiciel> est le nom de l’exécutable du logiciel d’édition et
    <nom du document> est le nom du document en cours d’édition par l’utilisateur (sans le chemin du fichier).

Par exemple : ``FCSC{calc.exe:Mes comptes 2025.txt}``.

### Binaire & Documents

````Bash
vol -f analyse-memoire.dmp windows.pstree.PsTree                                                                                                                                 ─╯
Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
PID     PPID    ImageFileName   Offset(V)       Threads Handles SessionId       Wow64   CreateTime      ExitTime        Audit   Cmd     Path

4       0       System  0xa50a1f85d080  178     -       N/A     False   2025-04-01 22:10:38.000000 UTC  N/A     -       -       -
.* 452   4       smss.exe        0xa50a20adc040  2       -       N/A     False   2025-04-01 22:10:38.000000 UTC  N/A     \Device\HarddiskVolume3\Windows\System32\smss.exe       \SystemRoot\System32\smss.exe  \SystemRoot\System32\smss.exe
.* 124   4       Registry        0xa50a1f8e1080  4       -       N/A     False   2025-04-01 22:10:34.000000 UTC  N/A     Registry        -       -
.* 1868  4       MemCompression  0xa50a270f1040  58      -       N/A     False   2025-04-01 22:10:45.000000 UTC  N/A     MemCompression  -       -
556     544     csrss.exe       0xa50a20adf080  11      -       0       False   2025-04-01 22:10:43.000000 UTC  N/A     \Device\HarddiskVolume3\Windows\System32\csrss.exe      %SystemRoot%\system32\csrss.exe ObjectDirectory=\Windows SharedSection=1024,20480,768 Windows=On SubSystemType=Windows ServerDll=basesrv,1 ServerDll=winsrv:UserServerDllInitialization,3 ServerDll=sxssrv,4 ProfileControl=Off MaxRequestThreads=16  C:\Windows\system32\csrss.exe

### ... 
### ...

.******* 9048    8968    soffice.bin     0xa50a297e7240  13      -       1       False   2025-04-01 22:11:34.000000 UTC  N/A     \Device\HarddiskVolume3\Program Files\LibreOffice\program\soffice.bin  "C:\Program Files\LibreOffice\program\soffice.exe" "-o" "C:\Users\userfcsc-10\Desktop\[SECRET-SF][TLP-RED]Plan FCSC 2026.odt" "-env:OOO_CWD=2C:\\Users\\userfcsc-10\\Desktop"  C:\Program Files\LibreOffice\program\soffice.bin
````

Sur la dernière ligne nous pouvons voir que le chemin de l'exe ``soffice.exe`` n'est pas celui officiel, on peut donc en conclure que c'est un logiciel malveillant. 

Le fichier qui a été ouverte est ``[SECRET-SF][TLP-RED]Plan FCSC 2026.odt``.

Le flag est donc : ``FCSC{soffice.exe:SECRET-SF][TLP-RED]Plan FCSC 2026.odt}``.



