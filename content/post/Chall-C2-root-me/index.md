+++
author = "Enzo"
title = "Chall - Command & Control"
date = "2025-12-28"
categories = [
    "Blue Team"
]
tags = [
    "Windows",
    "Forensic",
    "CTF",
    "Chall",
    "Volatility",
    "Root-Me"
]
+++
## Introduction

Challenge Root-Me


### Niveau 2
Berthier, grâce à vous la machine a été identifiée, vous avez demandé un dump de la mémoire vive de la machine et vous aimeriez bien jeter un coup d’œil aux logs de l’antivirus. Malheureusement, vous n’avez pas pensé à noter le nom de cette machine. Heureusement ce n’est pas un problème, vous disposez du dump de memoire.

Le mot de passe de validation est le nom de la machine.

#### Recherche
Nous avons donc un fichier, ``ch2.dmp``. Je lance un ``vol -h`` pour voir quel argument je peux utiliser pour avoir le nom du poste. 

J'ai un argument intéressant : 
````Bash
vol -h 
    windows.envars.Envars
                        Display process environment variables
````

En effet, les noms des ordinateurs/postes se trouve toujours dans les variables d'environnement. 
Nous lançons donc la commande suivante : 
```Bash
vol -f ch2.dmp windows.envars.Envars

Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
PID     Process Block   Variable        Value

...
560     services.exe    0x120ea8        COMPUTERNAME    WIN-ETSA91RKCFP
...
```

Nous avons maintenant récupérer le nom du poste, et donc, le flag du challenge.

### Niveau 3 
Berthier, l’antivirus n’a rien trouvé. A vous d’essayer de trouver le programme malveillant dans le dump de la mémoire vive. Le mot de passe de validation est le hash MD5 (en minuscules) du chemin d’accès absolu vers l’exécutable.

#### Recherche
Les programmes/processus sont lancé grâce à une commande. Pour connaître le programme malveillant nous pouvons utiliser l'argument ``windows.cmdline.CmdLine`` : 
````Bash
vol -f ch2.dmp windows.cmdline.CmdLine
Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
PID     Process Args

4       System  -
308     smss.exe        \SystemRoot\System32\smss.exe
404     csrss.exe       %SystemRoot%\system32\csrss.exe ObjectDirectory=\Windows SharedSection=1024,12288,512 Windows=On SubSystemType=Windows ServerDll=basesrv,1 ServerDll=winsrv:UserServerDllInitialization,3 ServerDll=winsrv:ConServerDllInitialization,2 ServerDll=sxssrv,4 ProfileControl=Off MaxRequestThreads=16
456     wininit.exe     -
468     csrss.exe       %SystemRoot%\system32\csrss.exe ObjectDirectory=\Windows SharedSection=1024,12288,512 Windows=On SubSystemType=Windows ServerDll=basesrv,1 ServerDll=winsrv:UserServerDllInitialization,3 ServerDll=winsrv:ConServerDllInitialization,2 ServerDll=sxssrv,4 ProfileControl=Off MaxRequestThreads=16
500     winlogon.exe    -
560     services.exe    C:\Windows\system32\services.exe
576     lsass.exe       C:\Windows\system32\lsass.exe
584     lsm.exe C:\Windows\system32\lsm.exe
692     svchost.exe     C:\Windows\system32\svchost.exe -k DcomLaunch
764     svchost.exe     C:\Windows\system32\svchost.exe -k RPCSS
832     svchost.exe     C:\Windows\System32\svchost.exe -k LocalServiceNetworkRestricted
904     svchost.exe     C:\Windows\System32\svchost.exe -k LocalSystemNetworkRestricted
928     svchost.exe     C:\Windows\system32\svchost.exe -k netsvcs
1084    svchost.exe     C:\Windows\system32\svchost.exe -k LocalService
1172    svchost.exe     C:\Windows\system32\svchost.exe -k NetworkService
1220    AvastSvc.exe    "C:\Program Files\AVAST Software\Avast\AvastSvc.exe"
1712    spoolsv.exe     C:\Windows\System32\spoolsv.exe
1748    svchost.exe     C:\Windows\system32\svchost.exe -k LocalServiceNoNetwork
1872    sppsvc.exe      -
1968    vmtoolsd.exe    "C:\Program Files\VMware\VMware Tools\vmtoolsd.exe"
336     wlms.exe        -
448     VMUpgradeHelpe  -
1612    TPAutoConnSvc.  "C:\Program Files\VMware\VMware Tools\TPAutoConnSvc.exe"
2352    taskhost.exe    "taskhost.exe"
2496    dwm.exe "C:\Windows\system32\Dwm.exe"
2548    explorer.exe    C:\Windows\Explorer.EXE
2568    TPAutoConnect.  TPAutoConnect.exe -q -i vmware -a COM1 -F 30
2600    conhost.exe     -
2660    VMwareTray.exe  "C:\Program Files\VMware\VMware Tools\VMwareTray.exe"
2676    VMwareUser.exe  "C:\Program Files\VMware\VMware Tools\VMwareUser.exe"
2720    AvastUI.exe     "C:\Program Files\AVAST Software\Avast\AvastUI.exe" /nogui
2744    StikyNot.exe    "C:\Windows\System32\StikyNot.exe"
2772    iexplore.exe    "C:\Users\John Doe\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\iexplore.exe"
2900    SearchIndexer.  C:\Windows\system32\SearchIndexer.exe /Embedding
3176    wmpnetwk.exe    "C:\Program Files\Windows Media Player\wmpnetwk.exe"
3352    svchost.exe     C:\Windows\system32\svchost.exe -k LocalServiceAndNoImpersonation
3452    swriter.exe     -
3512    soffice.exe     -
3556    soffice.bin     -
3564    soffice.bin     "C:\Program Files\LibreOffice 3.6\program\swriter.exe" "-o" "C:\Users\John Doe\Documents\Procedure Winpmemdump.odt" "--writer" "-env:OOO_CWD=2C:\\Users\\John Doe\\Documents"
3624    svchost.exe     C:\Windows\System32\svchost.exe -k secsvcs
1232    taskmgr.exe     "C:\Windows\system32\taskmgr.exe" /4
3152    cmd.exe "C:\Windows\system32\cmd.exe"
3228    conhost.exe     -
1616    cmd.exe cmd.exe
2168    conhost.exe     \??\C:\Windows\system32\conhost.exe
1136    iexplore.exe    "C:\Program Files\Internet Explorer\iexplore.exe"
3044    iexplore.exe    "C:\Program Files\Internet Explorer\iexplore.exe" SCODEF:1136 CREDAT:71937
1720    audiodg.exe     C:\Windows\system32\AUDIODG.EXE 0x298
3144    winpmem-1.3.1.  winpmem-1.3.1.exe  ram.dmp
````
Ici une commande m'interpele : 
```
C:\Users\John Doe\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\iexplore.exe
```
En effet, ce n'est pas un chemin "normal" pour un programme. 

Pour être sur nous pouvons regarder les connexions réseau de ce programme : 
````Bash
vol -f ch2.dmp windows.netscan.NetScan | grep iexplore
0x1dedb4f8 100.0TCPv4   127.0.0.1DB scan49178fin127.0.0.1       12080   ESTABLISHED     2772    iexplore.exe    -
0x1fa21008      TCPv4   127.0.0.1       58785   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fa3ea48      TCPv4   127.0.0.1       58808   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fa41008      TCPv4   127.0.0.1       58797   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fa468b0      TCPv4   127.0.0.1       58747   127.0.0.1       12080   CLOSED  3044    iexplore.exe    -
0x1fa5f3d8      TCPv4   127.0.0.1       58823   127.0.0.1       12080   CLOSED  3044    iexplore.exe    -
0x1fa78ac0      TCPv4   127.0.0.1       58806   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fa80880      TCPv4   127.0.0.1       58781   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fa83c98      TCPv4   127.0.0.1       58727   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fa859c0      TCPv4   127.0.0.1       58740   127.0.0.1       12080   CLOSED  3044    iexplore.exe    N/A
0x1fa9a678      TCPv4   127.0.0.1       58787   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1faa97f8      TCPv4   127.0.0.1       58742   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fab2008      TCPv4   127.0.0.1       58791   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fad2988      TCPv4   127.0.0.1       58749   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fada310      TCPv4   127.0.0.1       58733   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fae1ba0      TCPv4   127.0.0.1       58815   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1faeddf8      TCPv4   127.0.0.1       58811   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1faf7c58      TCPv4   127.0.0.1       58783   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fafe208      TCPv4   127.0.0.1       58738   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fb80df8      TCPv4   127.0.0.1       58792   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fbca1a0      UDPv4   127.0.0.1       60151   *       0               3044    iexplore.exe    2013-01-12 16:57:47.000000 UTC
0x1fca0820      TCPv4   127.0.0.1       58729   127.0.0.1       12080   CLOSED  3044    iexplore.exe    -
0x1fd57da0      TCPv4   127.0.0.1       58795   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fd92378      TCPv4   127.0.0.1       58817   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fd9b580      TCPv4   127.0.0.1       58731   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
0x1fd9f838      TCPv4   127.0.0.1       58758   127.0.0.1       12080   ESTABLISHED     3044    iexplore.exe    -
````
Ici nous pouvons être quasiement sur que ce programme est malveillant, car internet explorer n'est pas sensé communiqué en localhost et encore moins sur le port 12080. 

Pour avoir le flag, voici la commande qu'il faut entrer : 
````Bash
echo -n "C:\Users\John Doe\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\iexplore.exe" | md5sum
49979149632639432397b3a1df8cb43d
````

### Niveau 5 
Berthier, manifestement l’attaquant dispose des mots de passe des systèmes. Le programme malveillant semble être maintenu manuellement sur les machines. Le parc de la société ACME semblant à jour, c’est peut être les mots de passe qui sont faibles. John, l’administrateur des systèmes ne vous croit pas. Prouvez-lui.

Retrouvez le mot de passe de l’utilisateur.

#### Recherche
Grâce au cours de Christopher Thiefin (Processus Thief sur Youtube) je connais un argument dans volatility ``windows.hashdump.Hashdumps``. Nous allons donc utiliser cet argument pour récupérer le mot de passe de John : 
````Bash
vol -f ch2.dmp windows.hashdump.Hashdump
Volatility 3 Framework 2.27.0

User    rid     lmhash  nthash

Administrator   500     aad3b435b51404eeaad3b435b51404ee        31d6cfe0d16ae931b73c59d7e0c089c0
Guest   501     aad3b435b51404eeaad3b435b51404ee        31d6cfe0d16ae931b73c59d7e0c089c0
John Doe        1000    aad3b435b51404eeaad3b435b51404ee        b9f917853e3dbf6e6831ecce60725930
````
Ici, nous avons le hash du mot de passe de l'utilisateur John Doe. 

Nous allons le passer dans ``CrackStation`` pour l'avoir en clair. 
| Hash | Type | Result|
|:-------- |:--------:| --------:|
| b9f917853e3dbf6e6831ecce60725930     | NTLM   | passw0rd    |

