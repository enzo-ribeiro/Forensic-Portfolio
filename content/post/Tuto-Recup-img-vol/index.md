+++
author = "Enzo"
title = "Tuto - Profil personnalisé pour vol 3"
date = "2026-03-06"
categories = [
    "Blue Team"
]
tags = [
    "Forensic",
    "CTF",
    "Chall",
    "FCSC",
    "Root-Me",
    "Tuto",
	 "Mémoire"
]
+++
# Créer un profil Linux personnalisé pour Volatility 3

Ce guide explique comment générer soi-même un fichier ISF (Intermediate Symbol Format) au format JSON, requis par Volatility 3 pour analyser un dump mémoire Linux.

## La théorie : Pourquoi on fait ça ?

Quand un système d'exploitation est compilé (en C), le compilateur transforme toutes les structures de données (comme `task_struct` qui décrit un processus) en simples adresses mémoire et décalages (offsets). 
Pour que Volatility puisse lire le dump, il doit faire le chemin inverse : savoir à quel offset de la mémoire se trouve le nom du processus, son PID, etc. 

Pour cela, il lui faut le fichier **ISF** (Intermediate Symbol Format, un fichier JSON), qui est généré à partir des **symboles de débogage (DWARF)** du noyau exact qui tournait sur la machine.

---

## Étape 1 : Installer `dwarf2json`

`dwarf2json` est l'outil officiel de la fondation Volatility, écrit en Go, qui lit les fichiers de débogage Linux et génère le fichier ISF JSON.

1. Installez le langage Go si vous ne l'avez pas (via Homebrew sur macOS) :
   ```bash
   brew install go
   ```

2. Clonez et compilez `dwarf2json` :
   ```bash
   git clone https://github.com/volatilityfoundation/dwarf2json.git
   cd dwarf2json
   go build
   ```
   Vous avez maintenant un exécutable `./dwarf2json`.

---

## Étape 2 : Récupérer le bon noyau (Le plus difficile)

Dans notre cas, la version exacte du noyau trouvée dans le dump est **`5.4.0-4-amd64`** (version Debian `5.4.19-1`). 

Comme c'est un ancien noyau (début 2020), il n'est plus sur les dépôts classiques, il faut aller dans les archives (Snapshots) de Debian. Il nous faut :
1. Le **paquet de débogage** (qui contient le gros fichier `vmlinux` avec les symboles DWARF).
2. Le **paquet standard** (qui contient le fichier `System.map`).

Téléchargez les paquets depuis `snapshot.debian.org` en utilisant leur identifiant de fichier unique pour éviter les liens brisés :
```bash
brew instal wget
wget -O linux-image-5.4.0-4-amd64-dbg_5.4.19-1_amd64.deb http://snapshot.debian.org/file/9db55758ffb0c41d231243987f0d90df06ccdfab
wget -O linux-image-5.4.0-4-amd64_5.4.19-1_amd64.deb http://snapshot.debian.org/file/1cc1cbf519fc4a26aa470936a44ec1f2d1b19615
```

---

## Étape 3 : Extraire les fichiers (façon macOS)

Un fichier `.deb` est en fait une archive `ar` qui contient des fichiers `tar`. Sous macOS, comme on ne peut pas toujours utiliser `dpkg -x` nativement, on le fait manuellement.

1. Créez des dossiers pour extraire le contenu :
   ```bash
   mkdir pkg_dbg pkg_std
   ```

2. Extrayez le paquet de débogage (pour récupérer `vmlinux`) :
   ```bash
   cd pkg_dbg
   ar x ../linux-image-5.4.0-4-amd64-dbg_5.4.19-1_amd64.deb
   tar -xf data.tar.xz
   cd ..
   ```

3. Extrayez le paquet standard (pour récupérer `System.map`) :
   ```bash
   cd pkg_std
   ar x ../linux-image-5.4.0-4-amd64_5.4.19-1_amd64.deb
   tar -xf data.tar.xz
   cd ..
   ```

À ce stade, vos deux fichiers vitaux sont extraits :
- Le `vmlinux` est dans : `pkg_dbg/usr/lib/debug/boot/vmlinux-5.4.0-4-amd64`
- Le `System.map` est dans : `pkg_std/boot/System.map-5.4.0-4-amd64`

---

## Étape 4 : Générer le fichier JSON

Retournez dans le dossier où se trouve l'exécutable `dwarf2json` et lancez la génération en lui fournissant les deux fichiers :

```bash
./dwarf2json linux --elf pkg_dbg/usr/lib/debug/boot/vmlinux-5.4.0-4-amd64 --system-map pkg_std/boot/System.map-5.4.0-4-amd64 > debian-5.4.0-4-amd64.json
```

*Note : Cette commande prend quelques minutes et va consommer pas mal de mémoire RAM, c'est normal, l'outil décode tout l'arbre du noyau Linux !*

---

## Étape 5 : Installer le profil dans Volatility 3

Maintenant que vous avez votre fichier ISF (`debian-5.4.0-4-amd64.json`), il suffit de le mettre à la disposition de Volatility.

1. Allez dans le répertoire de votre installation de Volatility 3.
2. Repérez le dossier des symboles Linux, généralement : `volatility3/symbols/linux/` (ou `volatility3/volatility3/symbols/linux/`).
3. Placez-y votre fichier `debian-5.4.0-4-amd64.json`.

*(Astuce : Volatility gère les fichiers compressés pour gagner de la place, vous pouvez compresser le fichier avec `xz debian-5.4.0-4-amd64.json` pour obtenir un `.json.xz`)*.

Maintenant vous pouvez lancez vos commandes avec le bon profil. Volatility va scanner le dossier `symbols/linux/`, lire l'en-tête de votre dump mémoire, trouver que la signature correspond à votre fichier JSON, et vous afficher la liste des processus sans erreur !
