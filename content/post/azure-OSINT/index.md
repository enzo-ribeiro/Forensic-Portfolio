+++
author = "Enzo"
title = "Azure - OSINT"
date = "2026-06-18"
categories = [
    "Red Team"
]
tags = [
    "OSINT",
    "AD",
    "Azure",
    "CTF",
    "Cours"
]
+++
# Azure - OSINT
## Objectif ? 
L'objectif est de collecter des informations sur les utilisateurs du tenant, les ressources exposées et les noms de domaines liées à l'organisation. 

Dans cette phase, nous pouvons également faire la découverte deonnées sensible disponible ou non sur internet. 

## Recon externe passive - Utilisateurs

### Hunter.io
Hunter est une plateforme complète qui permet d'identifié les adresses mails et domaines associés à une entreprise.

Ce qui est intéresant avec Hunter.io, c'est qu'il (plus ou moins) trouver le poste de la personne, ce qui va nous permettre de faire du ciblage sur une personne qui à une fonction précise. 

Hunter va également également vérifier si l'adresse mail fournit est valide ou non.

Vous pouvez aller tester cet outil à cette URL : [https://hunter.io/](https://hunter.io/)

### ZoomInfo
ZoomInfo est un peu moins recommandé ... pas parce qu'il y a moins d'informations ou que la plateforme est moins fiable (niveau données). Mais simplement parce que si nous téléchargeons l'application, et que nous prenons la version gratuite, le binaire va siphonné nos contacts, adresse mail, etc. pour enrichir sa base de données. Il est conseillé de l'utiliser dans un environnement sécurisé et maîtrisé. 

Voici le lien de cette plateforme : [https://www.zoominfo.com/](https://www.zoominfo.com/)

## Recon externe active - CLI
Pour générer des (potentielle) adresses mail, nous pouvon également utiliser un outil en ligne de commande. Cet outil est `username-anarchy` disponible sur le repo github suivant : 
[https://github.com/urbanadventurer/username-anarchy](https://github.com/urbanadventurer/username-anarchy)

Pour l'installer il suffit de clonner le repo : 
````Bash
git clone https://github.com/urbanadventurer/username-anarchy
cd username-anarchy
````
Une fois dans le dossier `username-anarchy` nous pouvons installer ``ruby`` et lancer notre script : 
````Bash
sudo apt install ruby
ruby username-anarchy --suffix '@domaine.com' Enzo Ribeiro > emails.txt
````
Ensuite nous pouvons afficher le contenu de ``emails.txt`` : 
````Bash
cat emails.txt

enzo@domaine.com
enzoribeiro@domaine.com
enzo.ribeiro@domaine.com
enzoribe@domaine.com
enzor@domaine.com
e.ribeiro@domaine.com
eribeiro@domaine.com
renzo@domaine.com
r.enzo@domaine.com
ribeiroe@domaine.com
ribeiro@domaine.com
ribeiro.e@domaine.com
ribeiro.enzo@domaine.com
er@domaine.com
````

Une fois généré nous, pouvons les tester avec l'outil `o365enum`, disponible sur github au lien suivant : 
[https://github.com/gremwell/o365enum.git](https://github.com/gremwell/o365enum.git)

Pour l'installer, il suffit de suivre les étapes habituelle : 
````Bash
git clone https://github.com/gremwell/o365enum.git
cd o365enum
````
Une fois installer nous pouvons tester les mail pour savoir le quel est le bon. Ici nous utilsons `office.com` car c'est le plus fiable il a très peu de faux positif comparé aux autres "module" : 
````Bash
./o365enum.py -u ../username-anarchy/emails.txt -n 1 -m office.com
username,valid
enzo@domaine.com,0
enzoribeiro@domaine.com,0
enzo.ribeiro@domaine.com,1
enzoribe@domaine.com,0
enzor@domaine.com,0
e.ribeiro@domaine.com,0
eribeiro@domaine.com,0
renzo@domaine.com,0
r.enzo@domaine.com,0
ribeiroe@domaine.com,0
ribeiro@domaine.com,0
ribeiro.e@domaine.com,0
ribeiro.enzo@domaine.com,0
er@domaine.com,0
````
Dans le résultat de cette commande nous pouvons un résultat avec un `1` c'est la confirmation que c'est cette adresse qui existe et pas une autre.

Contrairement à l'autre méthode (passive), celle-ci génère un peu de bruit dans les logs, rien de bien fou, mais il est important de le savoir.
Même si cette méthode laisse passer du bruit dans les logs, elle reste ma préféré, car, plus fiable et nous pouvons avoir un grand nombre d'utilisateur. 

## Recon externe - Tenant
Pour commencer l'énumération du Tenant nous pouvons voir si l'entreprise possède un Tenant Azure avec le lien suivant : [https://login.microsoftonline.com/getuserrealm.srf?login=domain.com&xml=1](https://login.microsoftonline.com/getuserrealm.srf?login=domain.com&xml=1)
```Bash
curl -s "https://login.microsoftonline.com/getuserrealm.srf?login=<domain>&xml=1" | xmllint --format -
```
(Ici, j'ai rajouté un pipe pour mettre en forme la sortie de mon curl. Il est possible de ne pas mettre le pipe, voir même de rechercher cette URL sur un navigateur)
Voici la sortie de la commande ci-dessus : 
```Xml
<?xml version="1.0"?>
<RealmInfo Success="true">
  <State>4</State>
  <UserState>1</UserState>
  <Login>domain.com</Login>
  <NameSpaceType>Managed</NameSpaceType>
  <DomainName>domain.com</DomainName>
  <IsFederatedNS>false</IsFederatedNS>
  <FederationBrandName>Brand Name</FederationBrandName>
  <CloudInstanceName>microsoftonline.com</CloudInstanceName>
  <CloudInstanceIssuerUri>urn:federation:MicrosoftOnline</CloudInstanceIssuerUri>
</RealmInfo>
```
Voilà un petit tableau qui permet de mieux lire cet output : 
| Champ | Explication | Valeurs possibles |
|---|---|---|
| **Success** | La requête a abouti / domaine connu d'Entra ID | `true` domaine reconnu par Microsoft<br>`false` requête invalide ou domaine non résolu |
| **State** | État du domaine côté Microsoft | `0-3` états transitoires / non pleinement provisionné<br>`4` domaine existant et provisionné (tenant actif)<br>`5` domaine non managé / inconnu d'Entra ID |
| **UserState** | État du compte testé | `1` compte existant / état nominal<br>`autres` à comparer entre comptes pour inférer la validité |
| **NameSpaceType** | Mode d'authentification du domaine | `Managed` auth gérée par Entra ID → spray direct sur login.microsoftonline.com<br>`Federated` auth déléguée à un IdP (ADFS, Okta...) → champs AuthURL/STSAuthURL, spray sur l'IdP<br>`Unknown` domaine non géré par Entra ID ou inexistant |
| **IsFederatedNS** | Le namespace est-il fédéré ? | `false` cohérent avec Managed<br>`true` cohérent avec Federated (IdP externe) |
| **DomainName** | Domaine réel résolu côté tenant | `domaine.com` nom de domaine vérifié dans le tenant |
| **FederationBrandName** | Nom d'affichage de l'annuaire | `Default Directory` valeur par défaut<br>`<nom org>` souvent le nom réel de l'organisation |
| **CloudInstanceName** | Instance cloud du tenant | `microsoftonline.com` cloud commercial standard<br>`.us` / `.de` / `.cn` clouds souverains (GCC High, Allemagne, Chine) |
| **CloudInstanceIssuerUri** | Émetteur de jetons de l'instance | `urn:federation:MicrosoftOnline` cloud commercial standard |

Ensuite il est également possible d'identifier l'ID du tenant avec l'url suivante : 
```URL
https://login.microsoftonline.com/domaine.com/.well-known/openid-configuration
```

(Ici, je vais également faire un curl avec une "formatation" en json afin d'avoir un résultat propre) 

````Bash

curl https://login.microsoftonline.com/domaine.com/.well-known/openid-configuration | jq .
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100   1800 100   1800   0      0   7038      0                              0
{
  "token_endpoint": "https://login.microsoftonline.com/tenant-id/oauth2/token",
  "token_endpoint_auth_methods_supported": [
    "client_secret_post",
    "private_key_jwt",
    "client_secret_basic"
  ],
  "jwks_uri": "https://login.microsoftonline.com/common/discovery/keys",
  "response_modes_supported": [
    "query",
    "fragment",
    "form_post"
  ],
  "subject_types_supported": [
    "pairwise"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ],
  "response_types_supported": [
    "code",
    "id_token",
    "code id_token",
    "token id_token",
    "token"
  ],
  "scopes_supported": [
    "openid"
  ],
  "issuer": "https://sts.windows.net/tenant-id/",
  "microsoft_multi_refresh_token": true,
  "authorization_endpoint": "https://login.microsoftonline.com/tenant-id/oauth2/authorize",
  "device_authorization_endpoint": "https://login.microsoftonline.com/tenant-id/oauth2/devicecode",
  "http_logout_supported": true,
  "frontchannel_logout_supported": true,
  "end_session_endpoint": "https://login.microsoftonline.com/tenant-id/oauth2/logout",
  "claims_supported": [
    "sub",
    "iss",
    "cloud_instance_name",
    "cloud_instance_host_name",
    "cloud_graph_host_name",
    "msgraph_host",
    "aud",
    "exp",
    "iat",
    "auth_time",
    "acr",
    "amr",
    "nonce",
    "email",
    "given_name",
    "family_name",
    "nickname"
  ],
  "check_session_iframe": "https://login.microsoftonline.com/tenant-id/oauth2/checksession",
  "userinfo_endpoint": "https://login.microsoftonline.com/tenant-id/openid/userinfo",
  "kerberos_endpoint": "https://login.microsoftonline.com/tenant-id/kerberos",
  "tenant_region_scope": "EU",
  "cloud_instance_name": "microsoftonline.com",
  "cloud_graph_host_name": "graph.windows.net",
  "msgraph_host": "graph.microsoft.com",
  "rbac_url": "https://pas.windows.net"
}
````

Dans le résultat de la commande ci-dessus, nous pouvons y voir le `tenant-id` qui représante l'id du tenant. Ce n'est pas une faille en soit mais connaître cet ID peut nous faciliter la tâche lors de l'exploitation de certaines faille. 

## Recon externe - Tenant W/ Powershell
Pour réaliser sa collecte d'information avec powershell nous pouvons utiliser le module powershell `AADInternals` avec la commande suivante :
````Powershell
git clone https://github.com/Gerenios/AADInternals.git
Install-Module AADInternals
````

Une fois ça fait, nous pouvons nous réferer au tableau suivant : 

| Commande | Description | Utilité Red Team |
|---|---|---|
| `Get-AADIntLoginInformation -Domain <domain>` | Informations de connexion du tenant | Identifier le type d'auth (Managed/Federated) |
| `Get-AADIntTenantID -Domain <domain>` | Récupère l'ID du tenant | Nécessaire pour certaines exploitations |
| `Get-AADIntTenantDomains -Domain <domain>` | Liste tous les domaines du tenant | Élargir la surface d'attaque |
| `Invoke-AADIntReconAsOutsider -DomainName <domain>` | Recon complète depuis l'extérieur | SPF, DMARC, DKIM, MTA-STS, DesktopSSO |
| `Get-AADIntOpenIDConfiguration -Domain <domain>` | Configuration OpenID du tenant | Récupérer les endpoints OAuth2 |
| `Get-AADIntOAuthInfo -Domain <domain>` | Informations OAuth du tenant | Identifier les méthodes d'auth supportées |


Nous pouvons commencer en récupérant les information de connexion aux tenant : 
````Powershell 
Get-AADIntLoginInformation -Domain domaine.com
    ___    ___    ____  ____      __                        __
   /   |  /   |  / __ \/  _/___  / /____  _________  ____ _/ /____
  / /| | / /| | / / / // // __ \/ __/ _ \/ ___/ __ \/ __ `/ / ___/
 / ___ |/ ___ |/ /_/ _/ // / / / /_/  __/ /  / / / / /_/ / (__  )
/_/  |_/_/  |_/_____/___/_/ /_/\__/\___/_/  /_/ /_/\__,_/_/____/

 v0.9.8 by @DrAzureAD (Nestori Syynimaa)


Has Password                         : True
Federation Protocol                  :
Pref Credential                      : 1
Consumer Domain                      :
Cloud Instance audience urn          : urn:federation:MicrosoftOnline
Authentication Url                   :
Throttle Status                      : 0
Account Type                         : Managed
Federation Active Authentication Url :
Exists                               : 1
Federation Metadata Url              :
Desktop Sso Enabled                  :
Tenant Banner Logo                   : https://aadcdn.msauthimages.net/c1c6b6c8-cugao2godfjrg57da8gjgtdg0gcxafa-z4h8qyxtby/logintenantbranding/0/bannerlogo?ts=638658140324277492
Tenant Locale                        : 0
Cloud Instance                       : microsoftonline.com
State                                : 4
Domain Type                          : 3
Domain Name                          : domaine.com
Tenant Banner Illustration           : https://aadcdn.msauthimages.net/c1c6b6c8-cugao2godfjrg57da8gjgtdg0gcxafa-z4h8qyxtby/logintenantbranding/0/illustration?ts=638558122859906846
Federation Brand Name                : domaine
Federation Global Version            :
User State                           : 1
````
Grosso modo c'est les mêmes résultats qu'avec cette commande (vu précédemment) : 
```Bash
curl -s "https://login.microsoftonline.com/getuserrealm.srf?login=<domain>&xml=1" | xmllint --format -
```

Pour obtenir le `tenant-id` nous pouvons utiliser la commande : 
````Powershell
Get-AADIntTenantID -Domain domaine.com
<tenant-id>
````


Pour avoir des informations sur le SPF, DMARC, DKIM, MTA-STS etc. nous avons la commande : 
````Powershell
Invoke-AADIntReconAsOutsider -DomainName domaine.com

Tenant brand:       Tenant Brand
Tenant name:
Tenant id:          <tenant-id>
Tenant region:      EU
DesktopSSO enabled: False

Name    : domaine.com
DNS     : True
MX      : True
SPF     : True
DMARC   : True
DKIM    : False
MTA-STS : False
Type    : Managed
STS     :
````
(Si vous avez des erreurs sur cette commande c'est "normal")


## Recon externe - Sous-domaine
Pour passer à cette étape, nous avons ``yuyudhn`` qui a produit un outil qui automatisait cette recherche (ça facilite vraiment la reconnaissance). 

### AzSubEnum
On peut trouver cet outil sur le repo github suivant : 
[https://github.com/yuyudhn/AzSubEnum](https://github.com/yuyudhn/AzSubEnum)

Pour l'installer il suffit de clonner de repo : 
````Bash
git clone https://github.com/yuyudhn/AzSubEnum
````
Et de télécharger les dépendences : 
````Bash
pip3 install requests dnspython==2.4.2
````
Une fois téléchargé nous pouvons entrer la commande suivante : 
````Bash
python3 azsubenum.py -b domaine --thread 10

Discovered Subdomains:

App Services:
-----------------------------------
domaine.azurewebsites.net

Email:
---------------------------------------------
domaine.mail.protection.outlook.com

App Services - Management:
---------------------------------------
domaine.scm.azurewebsites.net

SharePoint:
--------------------------------
domaine.sharepoint.com
````
(/!\ quand nous déclarons le domain, il ne faut pas mettre l'extension ``.com``, `.fr` etc.)

Il est également de réaliser cette énumération avec le script Powershell MicroBurst : 
[https://github.com/NetSPI/MicroBurst](https://github.com/NetSPI/MicroBurst)

