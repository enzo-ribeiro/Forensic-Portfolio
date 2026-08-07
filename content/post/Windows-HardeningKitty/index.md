+++
author = "Enzo"
title = "Windows - HardeningKitty"
date = "2026-08-07"
categories = [
    "Blue Team"
]
tags = [
    "Windows",
    "Hardening",
    "Powershell"
]
+++
# Windows - HardeningKitty
## C'est quoi ? 
HardeningKitty est un module powershell qui va nous servir à auditer et à sécuriser les systèmes windows (Client ou Serveur), en utilisant différents "registres" / normes / standard (ex : CIS Benchmark, MSFT, DOD, BSI ...). 

Il est simple à télécharger, installer et mettre en marche. 

Nous pouvons avoir accès au `.zip` sur le github suivant : [HardeningKitty](https://github.com/0x6d69636b/windows_hardening)

## Installation
Pour installer le module `HardeningKitty` il suffit de télécharger l'archive sur le github (sur ce [lien directement](https://github.com/0x6d69636b/windows_hardening/archive/refs/tags/v.0.9.4.zip)) ou faire un ``git clone`` : 
````Powershell
git clone https://github.com/0x6d69636b/windows_hardening.git
````

Une fois télécharger il faut importer le module dans `Powershell` : 
````Powershell
Import-Module .\HardeningKitty.psm1
````

## Arborescence
L'arbrescence de `HardeningKitty` est assez simple et se comporte en 2 partie : 
 1. Script et module
````Powershell
> ls

    Directory: C:\Users\enzo\Downloads\HardeningKitty-v.0.9.4

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----          07/08/2026    14:41                lists
-----          20/07/2026    22:07           4361 HardeningKitty.psd1
-----          20/07/2026    22:07         183743 HardeningKitty.psm1
-----          20/07/2026    22:07           1064 LICENSE
-----          20/07/2026    22:07          43590 README.md
-----          20/07/2026    22:07          23285 Update-HardeningKittyListManifest.ps1
````
 2. Un dossier contenant les `.csv` de conformité
````Powershell
> ls

    Directory: C:\Users\enzo\Downloads\HardeningKitty-v.0.9.4\lists

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-----          20/07/2026    22:07         131254 finding_list_0x6d69636b_machine.csv
-----          20/07/2026    22:07          13660 finding_list_0x6d69636b_user.csv
-----          20/07/2026    22:07          37006 finding_list_bsi_sisyphus_windows_10_hd_machine.csv
-----          20/07/2026    22:07           1930 finding_list_bsi_sisyphus_windows_10_hd_user.csv
-----          20/07/2026    22:07         112796 finding_list_bsi_sisyphus_windows_10_nd_machine.csv
[...]
````


## Audit
Une fois importer nous pouvons lancer un audit avec la commande suivante (de mon côté j'ai choisis le CIS Benchmark pour ce post): 
````Powershell
Invoke-HardeningKitty -Mode Audit -FileFindingList .\lists\finding_list_cis_microsoft_windows_11_enterprise_24h2_user.csv 
````
Cette commande va nous renvoyer un "score" ce situant entre 1 et 6, 1 étant le moins sécurisé et 6 étant le top : 
| Score | Signification |
| :---- | :------------ |
| 6     | Excellent     |
| 5     | Bon           |
| 4     | Suffisant     |
| 3     | Insuffisant   |
| 2     | Insuffisant   |
| 1     | Insuffisant   |
(Tableau de [https://www.labouabouate.fr](https://www.labouabouate.fr))

En général, un score moyen est de 3. Exemple de retour sur ma machine : 
````Powershell
[*] 07/08/2026 15:11:55 - Your HardeningKitty score is: 3.28. HardeningKitty Statistics: Total checks: 573 - Passed: 152, Low: 17, Medium: 404, High: 0.
[*] 07/08/2026 15:11:55 - HardeningKitty is done
````

Ici nous pouvons voir que l'hardening de la machine laisse quand même à désiré ... Nous pouvons donc lancer le script pour qu'il puisse nous faire notre configuration à notre place. 

## Application des normes

### Poste local
Pour mettre en place les normes (exemple CIS Benchmark) il faut tout d'abord faire une backup du paramétrage actuelle (au cas où un paramètre ne correspond pas avec la façon d'utiliser votre PC). Nous pouvons le faire directement avec ``HardeningKitty` avec la commande suivante : 
````Powershell
Invoke-HardeningKitty -Mode Config -Backup
````

Une fois faite, nous pouvons lancer notre script voulu : 
````Powershell
Invoke-HardeningKitty -Mode HailMary -Log -Report -FileFindingList .\lists\finding_list_cis_microsoft_windows_11_enterprise_24h2_machine.csv
````

Si aucun/e des standards/normes ne vous convient (car trop restrictif ou pas assez) le créateur d'`HardeningKitty` à fait une interface web pour pouvoir créer sa propre configuration. Cette interface est disponible au lien suivant : [https://phi.cryptonit.fr/policies_hardening_interface/interface/windows/](https://phi.cryptonit.fr/policies_hardening_interface/interface/windows/)

### GPO
Une fonctionnalité très intéressante avec ``HardeningKitty`` c'est le fais de pouvoir transformer une conf en GPO pour la distribuer sur tout un parc informatique. 

Ce passage nécessite d'être administrateur du poste.

Voici un exemple avec le CIS Benchmark Winndows 11 24h2 : 
````Powershell
Invoke-HardeningKitty -Mode GPO -GPOName 'GPO_PC_Hardening' -Log -Report -FileFindingList .\lists\finding_list_cis_microsoft_windows_11_enterprise_24h2_machine.csv
````
Attention cette commande est à entrer si vous êtes administrateur d'un domaine, sinon elle échouera. Cette GPO va se créer dans le gestionnaire de GPO de votre domaine (il faut un accès RSAT pour ça) mais ne va pas s'appliquer, si vous voulez l'appliquez il faudra la lier à votre domaine. 

