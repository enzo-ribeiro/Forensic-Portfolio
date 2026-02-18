+++
author = "Enzo"
title = "Rubber Ducky pour 2€"
date = "2026-02-18"
categories = [
    "Red Team"
]
tags = [
    "Hack5",
    "HID",
    "Attack",
    "Rubber Ducky"
]
+++
## C'est quoi ? 

Une Rubber Ducky est une clef USB un peu spécial, en effet, elle est détecté par l'ordinateur comme un clavier, ce qui peut nous permettre d'y introduire des scripts qui exécute des frappes de clavier. 

## Installation 

Tout d'abord il faut se rendre sur le site d'Arduino dans la section ``software`` : 
https://www.arduino.cc/en/software/#ide

Une fois installer, nous pouvons lancer le logiciel et passer à la configuration. 

## Configuration

Pour configurer notre digispark il faut d'abord ajouter le bon packages sur le logiciel. 
Pour faire ça il nous suffit de suivre les étapes ci-dessous : 
 - Aller dans ``Arduino IDE`` en haut à droite (Je suis sur Mac, je vous met un tuto plutôt bien détaillé pour Linux et Windows)
 - Cliquer sur ``Préférences``
 - Dans ``Additional boards manager URLs`` on ajoute ce lien ``https://raw.githubusercontent.com/ArminJo/DigistumpArduino/master/package_digistump_index.json`` (c'est un lien mirroir de l'officiel, de mon côté impossible de joindre le lien officiel)
 - Puis cliquer sur ``OK``

Une fois le packages ``Digistump`` installé, il le faut télécharger dans ``Board Manager``, pour ça il faut : 
 - Aller dans ``Tools``
 - Puis dans ``Board: ``
 - Sélectionner ``Board Manager``
 - Un menu à gauche va s'ouvrir, il faut rechercher ``Digistump AVR Board`` et le télécharger. 
 - Une ça fait nous devons aller sélectionner notre digispark, nous suivrons le même chemin, donc ``Tools > Board:`` mais ici nous allons aller dans : ``Digistump AVR Boards > Digispark`` 

Maintenant nous avons notre "Rubber Ducky". Nous pouvons y mettre nos script personnalisé ou prendre ceux des personnes de la communauté.

Pour faire vos scripts, je vous conseil ce site ``https://cedarctic.github.io/digiQuack/`` il permet d'écrire les scripts en ``Duckyscript`` (bien plus simple) et il les convertiras en script Digispark.