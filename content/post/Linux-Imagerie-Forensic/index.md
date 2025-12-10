+++
author = "Enzo"
title = "Linux - Imagerie Forensic"
date = "2025-12-08"
categories = [
    "Linux"
]
tags = [
    "Linux",
    "Forensic",
    "Imagerie"
]
+++

## Introduction
Chaque OS a une structure et une configuration propre à eux, ils nécessite donc d'avoir plusieurs technique d'``Imaging``. Ici nous verrons comment faire une capture d'image d'un système Linux.
### Résumé des commandes et variables d'environnement :

1. **`set -o history`**  
    Active l’historique dans le shell, permettant d’enregistrer les commandes exécutées.
    
2. **`shopt -s histappend`**  
    Fait en sorte que les nouvelles commandes soient ajoutées au fichier d’historique, au lieu d’écraser le contenu précédent quand le shell se ferme.
    
3. **`export HISTCONTROL=`**  
    Supprime tous les filtres qui empêchent certaines commandes d’être sauvegardées. Ainsi, toutes les commandes sont enregistrées.
    
4. **`export HISTIGNORE=`**  
    Désactive l’exclusion de commandes spécifiques (par motif). Aucune commande n’est ignorée.
    
5. **`export HISTFILE=~/.bash_history`**  
    Définit le fichier où est stocké l’historique des commandes.
    
6. **`export HISTFILESIZE=-1`**  
    Supprime la limite du nombre de lignes stockées dans le fichier d’historique.
    
7. **`export HISTSIZE=-1`**  
    Supprime la limite du nombre de commandes retenues en mémoire dans l’historique de la session courante.
    
8. **`export HISTTIMEFORMAT="%F %R "`**  
    Ajoute un horodatage (AAAA-MM-JJ HH:MM) devant chaque commande sauvegardée dans l’historique
### Système de fichiers

#### Voir les disques montés sur la machine 
```zsh
df
```
![](Pasted-image-20251001094606.png)
Les disque physique sont identifié grave au ``/dev``. Le disque pour booté l'OS sur cette machine est ``/dev/root``. Ici le disque que nous allons monté n'est pas répertorié car c'est un disque virtuel attaché à une interface ``loop``. Nous pourrons voir notre disque virtuel avec ``lsblk -a``
![](Pasted-image-20251001095509.png)
(IMPORTANT: il est nécessaire de voir la taille du disque que nous allons "cloner" car il faut avoir la place nécessaire à ce clonnage sur notre machine)

On peut avoir plus d'info sur le disque avec la commande ``sudo losetup -l /dev/loop11`` 
![](Pasted-image-20251001100002.png)
Ou encore plus d'info comme l'UUID avec ``sudo blkid /dev/loop11``

![](Pasted-image-20251001100113.png)

### Question THM

```
Q : What command can be used to list all block devices in Linux OS?

A : lsblk
```

```
Q : Which bash command displays all commands executed in a session?

A : history
```

## Création de l'image
Dans cet exercice nous allons utiliser l'outil ``dc3dd``, une amélioration de la commande ``dd``. 

### Résumé clair des outils d’imagerie / récupération (version courte)

- **`dd`**  
    Utilitaire Unix standard pour copier et convertir des fichiers/flux. Souvent utilisé pour créer des images brutes de disques (`raw`), cloner des partitions ou écrire des images sur des périphériques. Simple, disponible partout, mais sans protections ni vérifications intégrées.
    
- **`dc3dd`**  
    Variante améliorée de `dd` orientée informatique légale : ajoute des fonctions comme le calcul d’hash (MD5/SHA1), enregistrement des métadonnées et options de logging. Utile quand tu veux créer des images tout en gardant des preuves vérifiables.
    
- **`ddrescue`**  
    Outil spécialisé en récupération de données depuis des supports dégradés. Copie intelligemment en plusieurs passes (priorise les zones lisibles puis tente les secteurs défectueux), garde une trace de l’état (fichier de log) pour reprendre la récupération. Idéal pour sauver un maximum de données sur un disque endommagé.
    
- **FTK Imager**  
    Outil graphique (GUI) largement utilisé en criminalistique numérique pour créer des images d’un disque, visualiser le contenu et exporter des fichiers. Pratique pour les utilisateurs qui préfèrent une interface visuelle et pour générer des images et rapports complets.
    
- **Guymager**  
    Imagerie médico-légale avec interface graphique, supporte plusieurs formats (raw, E01, etc.) et génère des logs détaillés. Conçu pour être rapide, multi-thread et convivial — bon choix pour examiner/imaginer plusieurs disques depuis une GUI sous Linux.
    
- **EWF tools (`ewfacquire`, etc.)**  
    Ensemble d’outils pour créer/manipuler des images au format Expert Witness Format (E01), le format courant en criminalistique. Permet d’acquérir des images compatibles avec d’autres suites forensiques et de gérer métadonnées et segments d’image.

Commençons la création de l'image : 
``sudo dc3dd if=/dev/loop11 of=example1.img log=imaging_loop11.txt``
 - if : fichier d'entrée 
 - of : fichier de sortie
 - log : enregistre les sorties dans ce fichier
 
![](Pasted-image-20251001101509.png)

Pour vérifier la sortie nous entrons cette commande : 
```Bash
ls -alh example1.img 
```
![](Pasted-image-20251001101729.png)
Nous pouvons voir que l'image fait la même taille que ``/dev/loop11``.

## Contrôle de l'intégrité 

Nous allons comparer le hash md5 pour vérifier l'intégrité du fichier. 
pour l'image que nous venons de faire : ``sudo md5sum example1.img``
![](Pasted-image-20251001102328.png)
pour le disque que nous avons "cloné" : ``sudo md5sum /dev/loop11``
![](Pasted-image-20251001102341.png)

## Autres types d'images

- **Imagerie à distance**  
    Acquisition d’une image via le **réseau**, sans accès physique direct à la machine.  
    🔹 Utile dans les enquêtes où la machine est éloignée ou doit rester en service.  
    🔹 Exemples : récupération sur un serveur distant, forensic à distance via SSH ou outils spécialisés.
    
- **Images USB**  
    Création d’une image complète du **contenu d’une clé USB** (ou tout autre périphérique amovible).  
    🔹 Permet de conserver une copie exacte (secteur par secteur).  
    🔹 Utile pour l’analyse forensique, la sauvegarde ou la duplication d’USB bootables.
    
- **Images Docker**  
    Snapshot du **système de fichiers et de la configuration d’un conteneur Docker**.  
    🔹 Pas une image disque classique, mais une image logicielle qui capture l’état et les dépendances d’un conteneur.  
    🔹 Utile pour figer l’environnement d’exécution d’une application et la partager/rejouer à l’identique.

Pour continuer l'exercice nous allons monté notre image ``example1.img`` avec la commande ``mount``, pour commencer le montage de cette image nous allons créer un point de montage dans ``/mnt/`` avec la commande ``sudo mkdir -p /mnt/example1``. 
![](Pasted-image-20251001103436.png)

Nous pouvons passer au montage : 
`sudo mount -o loop example1.img /mnt/example1`
![](Pasted-image-20251001103610.png)
Nous avons monté example1. 

## Cas pratique

```Bash
practical@ip-10-10-82-246:~$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0     7:0    0 28.1M  1 loop /snap/amazon-ssm-agent/2012
loop1     7:1    0 70.6M  1 loop /snap/lxd/16922
loop2     7:2    0 55.3M  1 loop /snap/core18/1885
loop3     7:3    0 97.8M  1 loop /snap/core/10185
loop4     7:4    0    1G  0 loop 
xvda    202:0    0   40G  0 disk 
└─xvda1 202:1    0   40G  0 part /
xvdh    202:112  0    1G  0 disk 
practical@ip-10-10-82-246:~$ sudo dc3dd if=/dev/loop4 of=loop4.img log=imaging_loop4.txt

dc3dd 7.2.646 started at 2025-10-01 09:07:30 +0000
compiled options:
command line: dc3dd if=/dev/loop4 of=loop4.img log=imaging_loop4.txt
device size: 2097152 sectors (probed),    1,073,741,824 bytes
sector size: 512 bytes (probed)
  1073741824 bytes ( 1 G ) copied ( 100% ),    5 s, 208 M/s                   

input results for device `/dev/loop4':
   2097152 sectors in
   0 bad sectors replaced by zeros

output results for file `loop4.img':
   2097152 sectors out

dc3dd completed at 2025-10-01 09:07:35 +0000

practical@ip-10-10-82-246:~$ ls -lah
total 1.1G
drwxr-xr-x 3 practical practical 4.0K Oct  1 09:07 .
drwxr-xr-x 4 root      root      4.0K Jul 15  2024 ..
-rw------- 1 practical practical    5 Jul 15  2024 .bash_history
-rw-r--r-- 1 practical practical  220 Jul 15  2024 .bash_logout
-rw-r--r-- 1 practical practical 3.7K Jul 15  2024 .bashrc
drwx------ 2 practical practical 4.0K Jul 15  2024 .cache
-rw-r--r-- 1 practical practical  807 Jul 15  2024 .profile
-rw-r--r-- 1 practical practical    0 Jul 15  2024 .sudo_as_admin_successful
-rw-r--r-- 1 root      root       501 Oct  1 09:07 imaging_loop4.txt
-rw-r--r-- 1 root      root      1.0G Oct  1 09:07 loop4.img
practical@ip-10-10-82-246:~$ sudo md5sum loop4.img 
1fab86e499934dda789c9c4aaf27101d  loop4.img
practical@ip-10-10-82-246:~$ sudo mkdir -p /mnt/loop4
practical@ip-10-10-82-246:~$ sudo mount -o loop loop4.img /mnt/loop4
practical@ip-10-10-82-246:~$ ls /mnt/loop4/
flag.txt  lost+found  testpractical01  testpractical02  testpractical03  testpractical04  testpractical05
practical@ip-10-10-82-246:~$ cat /mnt/loop4/flag.txt 
THM{well-done-imaginggggggg}
```


