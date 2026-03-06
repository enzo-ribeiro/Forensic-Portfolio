+++
author = "Enzo"
title = "Chall - FCSC Académie de l'investigation"
date = "2026-03-06"
categories = [
    "Blue Team"
]
tags = [
    "Forensic",
    "CTF",
    "Chall",
    "FCSC",
    "Mémoire",
    "Linux"
]
+++

## Académie de l'investigation - C'est la rentrée
Bienvenue à l’académie de l’investigation numérique ! Votre mission, valider un maximum d’étapes de cette série afin de démontrer votre dextérité en analyse mémoire GNU/Linux. Première étape : Retrouvez le `HOSTNAME`, le nom de l’utilisateur authentifié lors du dump et la version de Linux sur lequel le dump a été fait.

**Note :** Le flag est de la forme : `FCSC{hostname:user_name:x.x.x-x-amdxx}`.

### Recherche
Pour commencer on peut trouver assez facilement la version du Linux avec l'argument ``banners.Banners`` de vol : 
```Bash
vol -f dmp.mem banners.Banners

Volatility 3 Framework 2.27.0
Progress:  100.00               PDB scanning finished
Offset  Banner

0xc6001c0       Linux version 5.4.0-4-amd64 (debian-kernel@lists.debian.org) (gcc version 9.2.1 20200203 (Debian 9.2.1-28)) #1 SMP Debian 5.4.19-1 (2020-02-13)
0xd0303f4       Linux version 5.4.0-4-amd64 (debian-kernel@lists.debian.org) (gcc version 9.2.1 20200203 (Debian 9.2.1-28)) #1 SMP Debian 5.4.19-1 (2020-02-13)
0x4b500010      Linux version 5.4.0-4-amd64 (debian-kernel@lists.debian.org) (gcc version 9.2.1 20200203 (Debian 9.2.1-28)) #1 SMP Debian 5.4.19-1 (2020-02-13)
```

Nous pouvons lister les processus en cours d'exécution pour voir si certain nous intéresse, principalement un processus graphique (qui permet une interface, qui serait susceptible d'être utilisé par un user), ici ``xfce`` : 
```Bash
vol -f dmp.mem linux.pslist.PsList | grep xfce

0x9d72bd8c6c80.01201    1201    1171kingxfce4-session   1001    1001    1001    1001    2020-03-26 23:23:59.069470 UTC       Disabled
0x9d72bef48f80  1378    1378    1201    xfce4-panel     1001    1001    1001    1001    2020-03-26 23:23:59.713516 UTC       Disabled
0x9d72bebdae80  1415    1415    1       xfce4-power-man 1001    1001    1001    1001    2020-03-26 23:23:59.968899 UTC       Disabled
0x9d729ce79f00  1455    1455    1176    xfce4-notifyd   1001    1001    1001    1001    2020-03-26 23:24:00.085811 UTC       Disabled
```

Combiné à l'argument ``linux.envars.Envars``, avec PID 1201 nous obtenons l'utilisateur : 
```Bash
vol -f dmp.mem linux.envars.Envars | grep 1201 

1265ress1201    xfwm4   USER    Lesage
```

Toujours avec l'arg ``linux.envars.Envars``, nous pouvons retrouver le nom de la machine : 
```Bash
vol -f dmp.mem linux.envars.Envars | grep _MANAGER 

1378    1201    xfce4-panel     SESSION_MANAGER local/challenge.fcsc:@/tmp/.ICE-unix/1201,unix/challenge.fcsc:/tmp/.ICE-unix/1201
```

Donc avec un format de flag : ``FCSC{hostname:user_name:x.x.x-x-amdxx}`` Nous pouvons donc conclure que le flag résolu est : ``FCSC{challenge.fcsc:Lesage:5.4.0-4-amd64}``. 

## Académie de l'investigation - Administration
Ce poste administre un serveur distant avec le protole SSH à l’aide d’une authentification par clé (clé protégée par mot de passe). La clé publique a été utilisée pour chiffrer le message ci-joint (`flag.txt.enc`). Retrouvez et reconstituez la clé en mémoire qui permettra de déchiffrer ce message. Le fichier de dump à analyser est identique au challenge `C'est la rentrée`.

### Recherche
On sait que le protocole SSH utilise des clefs RSA, nous pouvons donc déjà lancé l'utilitaire ``rsakeyfind`` sur notre dump mémoire. 
```Bash 
git clone https://github.com/congwang/rsakeyfind.git
cd rsakeyfind
make
./rsakeyfind ../dmp.mem
FOUND PRIVATE KEY AT c64ac50
version =
00
modulus =
00 d7 1e 77 82 8c 92 31 e7 69 02 a2 d5 5c 78 de
a2 0c 8f fe 28 59 31 df 40 9c 60 61 06 b9 2f 62
40 80 76 cb 67 4a b5 59 56 69 17 07 fa f9 4c bd
6c 37 7a 46 7d 70 a7 67 22 b3 4d 7a 94 c3 ba 4b
7c 4b a9 32 7c b7 38 95 45 64 a4 05 a8 9f 12 7c
4e c6 c8 2d 40 06 30 f4 60 a6 91 bb 9b ca 04 79
11 13 75 f0 ae d3 51 89 c5 74 b9 aa 3f b6 83 e4
78 6b cd f9 5c 4c 85 ea 52 3b 51 93 fc 14 6b 33
5d 30 70 fa 50 1b 1b 38 81 13 8d f7 a5 0c c0 8e
f9 63 52 18 4e a9 f9 f8 5c 5d cd 7a 0d d4 8e 7b
ee 91 7b ad 7d b4 92 d5 ab 16 3b 0a 8a ce 8e de
47 1a 17 01 86 7b ab 99 f1 4b 0c 3a 0d 82 47 c1
91 8c bb 2e 22 9e 49 63 6e 02 c1 c9 3a 9b a5 22
1b 07 95 d6 10 02 50 fd fd d1 9b be ab c2 c0 74
d7 ec 00 fb 11 71 cb 7a dc 81 79 9f 86 68 46 63
82 4d b7 f1 e6 16 6f 42 63 f4 94 a0 ca 33 cc 75
13
publicExponent =
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 01
privateExponent =
62 b5 60 31 4f 3f 66 16 c1 60 ac 47 2a ff 6b 69
00 4a b2 5c e1 50 b9 18 74 a8 e4 dc a8 ec cd 30
bb c1 c6 e3 c6 ac 20 2a 3e 5e 8b 12 e6 82 08 09
38 0b ab 7c b3 cc 9c ce 97 67 dd ef 95 40 4e 92
e2 44 e9 1d c1 14 fd a9 b1 dc 71 9c 46 21 bd 58
88 6e 22 15 56 c1 ef e0 c9 8d e5 80 3e da 7e 93
0f 52 f6 f5 c1 91 90 9e 42 49 4f 8d 9c ba 38 83
e9 33 c2 50 4f ec c2 f0 a8 b7 6e 28 25 56 6b 62
67 fe 08 f1 56 e5 6f 0e 99 f1 e5 95 7b ef eb 0a
2c 92 97 57 23 33 36 07 dd fb ae f1 b1 d8 33 b7
96 71 42 36 c5 a4 a9 19 4b 1b 52 4c 50 69 91 f0
0e fa 80 37 4b b5 d0 2f b7 44 0d d4 f8 39 8d ab
71 67 59 05 88 3d eb 48 48 33 88 4e fe f8 27 1b
d6 55 60 5e 48 b7 6d 9a a8 37 f9 7a de 1b cd 5d
1a 30 d4 e9 9e 5b 3c 15 f8 9c 1f da d1 86 48 55
ce 83 ee 8e 51 c7 de 32 12 47 7d 46 b8 35 df 41
prime1 =
00
prime2 =
00
exponent1 =
00
exponent2 =
00
coefficient =
00

FOUND PRIVATE KEY AT 1084c490
version =
00
modulus =
00 d7 1e 77 82 8c 92 31 e7 69 02 a2 d5 5c 78 de
a2 0c 8f fe 28 59 31 df 40 9c 60 61 06 b9 2f 62
40 80 76 cb 67 4a b5 59 56 69 17 07 fa f9 4c bd
6c 37 7a 46 7d 70 a7 67 22 b3 4d 7a 94 c3 ba 4b
7c 4b a9 32 7c b7 38 95 45 64 a4 05 a8 9f 12 7c
4e c6 c8 2d 40 06 30 f4 60 a6 91 bb 9b ca 04 79
11 13 75 f0 ae d3 51 89 c5 74 b9 aa 3f b6 83 e4
78 6b cd f9 5c 4c 85 ea 52 3b 51 93 fc 14 6b 33
5d 30 70 fa 50 1b 1b 38 81 13 8d f7 a5 0c c0 8e
f9 63 52 18 4e a9 f9 f8 5c 5d cd 7a 0d d4 8e 7b
ee 91 7b ad 7d b4 92 d5 ab 16 3b 0a 8a ce 8e de
47 1a 17 01 86 7b ab 99 f1 4b 0c 3a 0d 82 47 c1
91 8c bb 2e 22 9e 49 63 6e 02 c1 c9 3a 9b a5 22
1b 07 95 d6 10 02 50 fd fd d1 9b be ab c2 c0 74
d7 ec 00 fb 11 71 cb 7a dc 81 79 9f 86 68 46 63
82 4d b7 f1 e6 16 6f 42 63 f4 94 a0 ca 33 cc 75
13
publicExponent =
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 01
privateExponent =
62 b5 60 31 4f 3f 66 16 c1 60 ac 47 2a ff 6b 69
00 4a b2 5c e1 50 b9 18 74 a8 e4 dc a8 ec cd 30
bb c1 c6 e3 c6 ac 20 2a 3e 5e 8b 12 e6 82 08 09
38 0b ab 7c b3 cc 9c ce 97 67 dd ef 95 40 4e 92
e2 44 e9 1d c1 14 fd a9 b1 dc 71 9c 46 21 bd 58
88 6e 22 15 56 c1 ef e0 c9 8d e5 80 3e da 7e 93
0f 52 f6 f5 c1 91 90 9e 42 49 4f 8d 9c ba 38 83
e9 33 c2 50 4f ec c2 f0 a8 b7 6e 28 25 56 6b 62
67 fe 08 f1 56 e5 6f 0e 99 f1 e5 95 7b ef eb 0a
2c 92 97 57 23 33 36 07 dd fb ae f1 b1 d8 33 b7
96 71 42 36 c5 a4 a9 19 4b 1b 52 4c 50 69 91 f0
0e fa 80 37 4b b5 d0 2f b7 44 0d d4 f8 39 8d ab
71 67 59 05 88 3d eb 48 48 33 88 4e fe f8 27 1b
d6 55 60 5e 48 b7 6d 9a a8 37 f9 7a de 1b cd 5d
1a 30 d4 e9 9e 5b 3c 15 f8 9c 1f da d1 86 48 55
ce 83 ee 8e 51 c7 de 32 12 47 7d 46 b8 35 df 41
prime1 =
00
prime2 =
00
exponent1 =
00
exponent2 =
00
coefficient =
00
```

Maintenant, nous pouvons déchiffré le fichier ``.enc`` avec la formule mathématique : ``clair = (chiffré ** exposant_privé) % module`` : 
```Python
from Crypto.Util.number import bytes_to_long,long_to_bytes

N = 0x00d71e77828c9231e76902a2d55c78dea20c8ffe285931df409c606106b92f62408076cb674ab55956691707faf94cbd6c377a467d70a76722b34d7a94c3ba4b7c4ba9327cb738954564a405a89f127c4ec6c82d400630f460a691bb9bca0479111375f0aed35189c574b9aa3fb683e4786bcdf95c4c85ea523b5193fc146b335d3070fa501b1b3881138df7a50cc08ef96352184ea9f9f85c5dcd7a0dd48e7bee917bad7db492d5ab163b0a8ace8ede471a1701867bab99f14b0c3a0d8247c1918cbb2e229e49636e02c1c93a9ba5221b0795d6100250fdfdd19bbeabc2c074d7ec00fb1171cb7adc81799f86684663824db7f1e6166f4263f494a0ca33cc7513
d = 0x62b560314f3f6616c160ac472aff6b69004ab25ce150b91874a8e4dca8eccd30bbc1c6e3c6ac202a3e5e8b12e6820809380bab7cb3cc9cce9767ddef95404e92e244e91dc114fda9b1dc719c4621bd58886e221556c1efe0c98de5803eda7e930f52f6f5c191909e42494f8d9cba3883e933c2504fecc2f0a8b76e2825566b6267fe08f156e56f0e99f1e5957befeb0a2c92975723333607ddfbaef1b1d833b796714236c5a4a9194b1b524c506991f00efa80374bb5d02fb7440dd4f8398dab71675905883deb484833884efef8271bd655605e48b76d9aa837f97ade1bcd5d1a30d4e99e5b3c15f89c1fdad1864855ce83ee8e51c7de3212477d46b835df41

c = bytes_to_long(open("flag.txt.enc", 'rb').read())

print(f"---MODULUS IS {N}---")
print(f"---privexp IS {d}---")
print(f"---ciphert IS {c}---")

print(long_to_bytes(pow(c,d,N)))
```

En exécutant le script python nous retrouvons le flag : 
``FCSC{ac5cad66114d4866a4b55e43cb8896cc4947855241b5af8d2f8a123c36083d98}``.

## Académie de l'investigation - Premiers artéfacts

Pour avancer dans l’analyse, vous devez retrouver :

- Le nom de processus ayant le PID `1254`.
- La commande exacte qui a été exécutée le `2020-03-26 23:29:19 UTC`.
- Le nombre de connexions réseau `TCP` et `UDP` établies lors du dump avec `Peer Address` unique.

**Note :** le flag est au format `FCSC{nom_du_processus:une_commande:n_connexions}`.

### Recherche

Pour le processus avec le PID 1254, nous avons l'argument ``linux/psscan.PsScan`` : 
```Bash
vol -f dmp.mem linux.psscan.PsScan | grep 1254

0x3fdccd80 100.01251    1254    1176    pool-xfconfd    EXIT_DEAD
```

Pour la commande nous avons l'argument ``linux.bash.Bash`` : 
```Bash 
vol -f dmp.mem linux.bash.Bash | grep "2020-03-26 23:29:19.000000"

1523    bash    2020-03-26 23:29:19.000000 UTC  nmap -sS -sV 10.42.42.0/24
```

Pour le nombre de connexion, je préfère utiliser volatility2, je le trouve plus pertinent et plus simple pour cet usage : 
```Bash
vol2 linux_netstat --output=greptext | grep ESTABLISHED | cut -d"|" -f5 | sort | uniq | wc -l
13
```

Ce qui nous donne le flag suivant : 
``FCSC{pool-xfconfd:nmap -sS -sV 10.42.42.0/24:13}``


